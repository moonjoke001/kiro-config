---
inclusion: manual
---

# SAM-Audio (Segment Anything Model for Audio)

Meta AI 开源的音频分割基础模型，可通过文本、视觉或时间提示从复杂音频混合中分离特定声音。

## 项目概述

- **仓库**: https://github.com/facebookresearch/sam-audio
- **论文**: https://arxiv.org/abs/2512.18099
- **许可**: SAM License
- **Python**: >= 3.11
- **核心依赖**: PyTorch, torchaudio, transformers, perception-models, dacvae, imagebind, laion-clap

## 核心架构

### 模型组件 (`sam_audio/model/`)

```
SAMAudio
├── audio_codec (DACVAE)        # 音频编解码器，48kHz采样率
├── text_encoder (T5TextEncoder) # T5文本编码器
├── vision_encoder (PerceptionEncoder) # PE-Core视觉编码器
├── transformer (DiT)           # Diffusion Transformer
├── align_masked_video          # 视频特征对齐模块
├── embed_anchors               # 时间锚点嵌入
├── visual_ranker               # ImageBind视觉排序器
├── text_ranker                 # CLAP/Judge文本排序器
└── span_predictor              # PE-AV时间跨度预测器
```

### 关键类

1. **SAMAudio** (`model/model.py`): 主模型类
   - `separate()`: 核心分离方法，支持ODE求解
   - `predict_spans()`: 自动预测目标声音时间跨度
   - 使用 `torchdiffeq.odeint` 进行流匹配生成

2. **DiT** (`model/transformer.py`): Diffusion Transformer
   - RMSNorm + RoPE位置编码
   - Cross-attention用于文本/视觉条件
   - AdaLN-Zero调制机制

3. **DACVAE** (`model/codec.py`): 音频编解码器
   - hop_length = 1920 (encoder_rates: [2,8,10,12])
   - latent_dim = 1024
   - 48kHz采样率

4. **SAMAudioProcessor** (`processor.py`): 数据预处理
   - 音频批处理和重采样
   - 视频帧加载和对齐
   - 锚点(anchor)处理

### 排序模块 (`sam_audio/ranking/`)

- **ClapRanker**: 音频-文本相似度
- **ImageBindRanker**: 音频-视频相似度
- **JudgeRanker**: 分离质量评估 (precision/recall/faithfulness)
- **EnsembleRanker**: 组合排序器

## 三种提示方式

### 1. 文本提示 (Text Prompting)
```python
processor(audios=[audio], descriptions=["man speaking"])
# 使用小写名词/动词短语格式
```

### 2. 视觉提示 (Visual Prompting)
```python
masked_video = processor.mask_videos([frames], [mask])
processor(audios=[video], descriptions=[""], masked_videos=masked_video)
```

### 3. 时间跨度提示 (Span Prompting)
```python
processor(audios=[audio], descriptions=["car honking"], 
          anchors=[[["+", 6.3, 7.0]]])  # "+"表示正样本
```

## 推理流程

```python
# 1. 加载模型
model = SAMAudio.from_pretrained("facebook/sam-audio-large")
processor = SAMAudioProcessor.from_pretrained("facebook/sam-audio-large")

# 2. 预处理
batch = processor(audios=[file], descriptions=[desc]).to("cuda")

# 3. 分离
result = model.separate(
    batch, 
    predict_spans=True,      # 自动预测时间跨度
    reranking_candidates=8   # 生成8个候选，选最佳
)

# 4. 输出
# result.target: 目标音频
# result.residual: 残余音频
```

## 模型变体

| 模型 | 特点 |
|------|------|
| sam-audio-small/base/large | 通用版本 |
| sam-audio-small-tv/base-tv/large-tv | 视觉提示优化版 |

## 评估指标 (`eval/`)

- **Judge**: 分离质量 (Overall/Faithfulness/Recall/Precision)
- **Aesthetic**: 音频美学质量
- **CLAP**: 音频-文本对齐
- **ImageBind**: 音频-视频对齐 (视觉提示)

## 关键配置

### SAMAudioConfig
```python
in_channels = 768
num_anchors = 3
anchor_embedding_dim = 128
audio_codec.sample_rate = 48000
audio_codec.hop_length = 1920
text_encoder.dim = 768
vision_encoder.dim = 1024
transformer.dim = 2048
transformer.n_heads = 16
transformer.n_layers = 16
```

## 开发注意事项

1. **HuggingFace认证**: 需要申请模型访问权限并登录
2. **GPU要求**: 推荐CUDA GPU，模型较大
3. **文本格式**: 使用小写名词/动词短语，避免完整句子
4. **性能优化**: 
   - `predict_spans=True` 提升非环境音分离效果
   - `reranking_candidates=8` 提升质量但增加延迟
5. **音频格式**: 自动重采样到48kHz

## 文件结构

```
sam_audio/
├── __init__.py
├── processor.py          # 数据预处理
├── model/
│   ├── model.py          # SAMAudio主模型
│   ├── config.py         # 配置类
│   ├── transformer.py    # DiT实现
│   ├── codec.py          # DACVAE编解码器
│   ├── align.py          # 模态对齐
│   ├── text_encoder.py   # T5编码器
│   ├── vision_encoder.py # PE-Core编码器
│   ├── judge.py          # Judge模型
│   └── rope.py           # 旋转位置编码
└── ranking/
    ├── ranker.py         # 排序器基类
    ├── clap.py           # CLAP排序
    ├── imagebind.py      # ImageBind排序
    └── judge.py          # Judge排序
```

## 常用命令

```bash
# 安装
pip install .

# 评估
python eval/main.py --setting sfx speech music
torchrun --nproc_per_node=4 eval/main.py  # 多GPU

# HuggingFace登录
huggingface-cli login
```

