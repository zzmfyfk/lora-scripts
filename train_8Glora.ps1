# LoRA train script by @Akegarasu modify by @bdsqlsz

#训练模式(Lora、db、Sdxl_lora、Sdxl_db、controlnet(未完成))
$train_mode = "sdxl_lora"

# Train data path | 设置训练用模型、图片
$pretrained_model = "./Stable-diffusion/sd_xl_base_1.0_fixvae_fp16.safetensors" # base model path | 底模路径
$vae = ""
$is_v2_model = 0 # SD2.0 model | SD2.0模型 2.0模型下 clip_skip 默认无效
$v_parameterization = 0 # parameterization | 参数化 v2 非512基础分辨率版本必须使用。
$train_data_dir = "./train/color_trace" # train dataset path | 训练数据集路径
$reg_data_dir = ""	# reg dataset path | 正则数据集化路径
$network_weights = "" # pretrained weights for LoRA network | 若需要从已有的 LoRA 模型上继续训练，请填写 LoRA 模型路径。
$training_comment = "this LoRA model created from bdsqlsz by bdsqlsz'script" # training_comment | 训练介绍，可以写作者名或者使用触发关键词
$dataset_class = ""

#差异炼丹法
$base_weights = "" #指定合并到底模basemodel中的模型路径，多个用空格隔开。默认为空，不使用。
$base_weights_multiplier = "1.0" #指定合并模型的权重，多个用空格隔开，默认为1.0。

# Train related params | 训练相关参数
$resolution = "1024,1024" # image resolution w,h. 图片分辨率，宽,高。支持非正方形，但必须是 64 倍数。
$batch_size = 1 # batch size 一次性训练图片批处理数量，根据显卡质量对应调高。
$max_train_epoches = 40 # max train epoches | 最大训练 epoch
$save_every_n_epochs = 10 # save every n epochs | 每 N 个 epoch 保存一次

$gradient_checkpointing = 1 #梯度检查，开启后可节约显存，但是速度变慢
$gradient_accumulation_steps = 0 # 梯度累加数量，变相放大batchsize的倍数

$network_dim = 32 # network dim | 常用 4~128，不是越大越好
$network_alpha = 16 # network alpha | 常用与 network_dim 相同的值或者采用较小的值，如 network_dim的一半 防止下溢。默认值为 1，使用较小的 alpha 需要提升学习率。

#dropout | 抛出(目前和lycoris不兼容，请使用lycoris自带dropout)
$network_dropout = 0 # dropout 是机器学习中防止神经网络过拟合的技术，建议0.1~0.3 
$scale_weight_norms = 1.0 #配合 dropout 使用，最大范数约束，推荐1.0
$rank_dropout = 0 #lora模型独创，rank级别的dropout，推荐0.1~0.3，未测试过多
$module_dropout = 0 #lora模型独创，module级别的dropout(就是分层模块的)，推荐0.1~0.3，未测试过多

$train_unet_only = 1 # train U-Net only | 仅训练 U-Net，开启这个会牺牲效果大幅减少显存使用。6G显存可以开启
$train_text_encoder_only = 0 # train Text Encoder only | 仅训练 文本编码器

$seed = 1026 # reproducable seed | 设置跑测试用的种子，输入一个prompt和这个种子大概率得到训练图。可以用来试触发关键词

#noise | 噪声
$noise_offset = 0 # help allow SD to gen better blacks and whites，(0-1) | 帮助SD更好分辨黑白，推荐概念0.06，画风0.1
$adaptive_noise_scale = 0 #自适应偏移调整，10%~100%的noiseoffset大小
$multires_noise_iterations = 6 #多分辨率噪声扩散次数，推荐6-10,0禁用。
$multires_noise_discount = 3 #多分辨率噪声缩放倍数，推荐0.1-0.3,上面关掉的话禁用。

#lycoris组件
$enable_lycoris = 0 # 开启lycoris
$conv_dim = 0 #卷积 dim，推荐＜32
$conv_alpha = 0 #卷积 alpha，推荐1或者0.3
$algo = "loha" # algo参数，指定训练lycoris模型种类，包括lora(就是locon)、loha、IA3以及lokr、dylora ，5个可选
$dropout = 0 #lycoris专用dropout

#dylora组件
$enable_dylora = 0 # 开启dylora，和lycoris冲突，只能开一个。
$unit = 4 #分割块数单位，最小1也最慢。一般4、8、12、16这几个选

# Learning rate | 学习率
$lr = "2e-4"
$unet_lr = "1e-5"
$text_encoder_lr = "2e-5"
$lr_scheduler = "constant_with_warmup" # "linear", "cosine", "cosine_with_restarts", "polynomial", "constant", "constant_with_warmup" | PyTorch自带6种动态学习率函数
# constant，常量不变, constant_with_warmup 线性增加后保持常量不变, linear 线性增加线性减少, polynomial 线性增加后平滑衰减, cosine 余弦波曲线, cosine_with_restarts 余弦波硬重启，瞬间最大值。
# 推荐默认cosine_with_restarts或者polynomial，配合输出多个epoch结果更玄学
$lr_warmup_steps = 50 # warmup steps | 学习率预热步数，lr_scheduler 为 constant 或 adafactor 时该值需要设为0。仅在 lr_scheduler 为 constant_with_warmup 时需要填写这个值
$lr_scheduler_num_cycles = 1 # restarts nums | 余弦退火重启次数，仅在 lr_scheduler 为 cosine_with_restarts 时需要填写这个值

# 优化器
$optimizer_type = "PagedAdamW8bit" 
# 可选优化器"adaFactor","AdamW","AdamW8bit","Lion","SGDNesterov","SGDNesterov8bit","DAdaptation",  
# 新增优化器"Lion8bit"(速度更快，内存消耗更少)、"DAdaptAdaGrad"、"DAdaptAdan"(北大最新算法，效果待测)、"DAdaptSGD"
# 新增DAdaptAdam、DAdaptLion、DAdaptAdanIP，强烈推荐DAdaptAdam
# 新增优化器"Sophia"(2倍速1.7倍显存)、"Prodigy"天才优化器，可自适应Dylora
# PagedAdamW8bit、PagedLion8bit、Adan、Tiger
$d_coef="0.5"
$d0 = "2e-4" #dadaptation以及prodigy初始学习率

$shuffle_caption = 1 # 随机打乱tokens
$keep_tokens = 1 # keep heading N tokens when shuffling caption tokens | 在随机打乱 tokens 时，保留前 N 个不变。
$prior_loss_weight = 1 #正则化权重,0-1
$min_snr_gamma = 5 #最小信噪比伽马值，减少低step时loss值，让学习效果更好。推荐3-5，5对原模型几乎没有太多影响，3会改变最终结果。修改为0禁用。

$weighted_captions=0 #权重打标，默认识别标签权重，语法同webui基础用法。例如(abc), [abc],(abc:1.23),但是不能在括号内加逗号，否则无法识别。一个文件最多75个tokens。

# block weights | 分层训练
$enable_block_weights=0 #开启分层训练，和lycoris冲突，只能开一个。
$down_lr_weight="1,0.2,1,1,0.2,1,1,0.2,1,1,1,1" #12层，需要填写12个数字，0-1.也可以使用函数写法，支持sine, cosine, linear, reverse_linear, zeros，参考写法down_lr_weight=cosine+.25 
$mid_lr_weight="1"  #1层，需要填写1个数字，其他同上。
$up_lr_weight="1,1,1,1,1,1,1,1,1,1,1,1"   #12层，同上上。
$block_lr_zero_threshold=0  #如果分层权重不超过这个值，那么直接不训练。默认0。

$enable_block_dim=0 #开启dim分层训练
$block_dims="128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128" #dim分层，25层
$block_alphas="16,16,32,16,32,32,64,16,16,64,64,64,16,64,16,64,32,16,16,64,16,16,16,64,16"  #alpha分层，25层
$conv_block_dims="32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32" #convdim分层，25层
$conv_block_alphas="1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1" #convalpha分层，25层


# Output settings | 输出设置
$output_name = "sdxl_8glora" # output model name | 模型保存名称
$save_model_as = "safetensors" # model save ext | 模型保存格式 ckpt, pt, safetensors
$mixed_precision = "bf16" # bf16效果更好，默认fp16
$save_precision="bf16" # bf16效果更好，默认fp16
$full_fp16 = 0 #开启全fp16模式，自动混合精度变为fp16，更节约显存，实验性功能
$full_bf16 = 1 #选择全bf16训练，必须30系以上显卡。

# Resume training state | 恢复训练设置
$save_state = 0 # save training state | 保存训练状态 名称类似于 <output_name>-??????-state ?????? 表示 epoch 数
$resume = "" # resume from state | 从某个状态文件夹中恢复训练 需配合上方参数同时使用 由于规范文件限制 epoch 数和全局步数不会保存 即使恢复时它们也从 1 开始 与 network_weights 的具体实现操作并不一致

#保存toml文件
$output_config = 0 #开启后直接输出一个toml配置文件，但是无法同时训练，需要关闭才能正常训练。
$config_file = "./toml/"+ $output_name +".toml" #输出文件保存目录和文件名称，默认用模型保存同名。

#输出采样图片
$enable_sample = 0 #1开启出图，0禁用
$sample_every_n_epochs = 5 #每n个epoch出一次图
$sample_prompts="./toml/1girl.txt" #prompt文件路径
$sample_sampler="ddim" #采样器 'ddim', 'pndm', 'heun', 'dpmsolver', 'dpmsolver++', 'dpmsingle', 'k_lms', 'k_euler', 'k_euler_a', 'k_dpm_2', 'k_dpm_2_a'

#wandb 日志同步
$wandb_api_key="" # wandbAPI KEY，用于登录

# 其他设置
$enable_bucket = 1 #开启分桶
$min_bucket_reso = 640 # arb min resolution | arb 最小分辨率
$max_bucket_reso = 1536 # arb max resolution | arb 最大分辨率
$persistent_workers = 1 # makes workers persistent, further reduces/eliminates the lag in between epochs. however it may increase memory usage | 跑的更快，吃内存。大概能提速2倍
$vae_batch_size = 4 #vae批处理大小，2-4
$clip_skip = 2 # clip skip | 玄学 一般用 2
$cache_latents = 1 #缓存潜变量
$cache_latents_to_disk = 1 # 缓存图片存盘，下次训练不需要重新缓存，1开启0禁用

#SDXL专用参数
#https://www.bilibili.com/video/BV1tk4y137fo/
$min_timestep = 0 #最小时序，默认值0
$max_timestep = 1000 #最大时序，默认值1000
$cache_text_encoder_outputs = 1 #开启缓存文本编码器，开启后减少显存使用。但是无法和shuffle共用
$cache_text_encoder_outputs_to_disk = 1 #开启缓存文本编码器，开启后减少显存使用。但是无法和shuffle共用
$no_half_vae = 0 #禁止半精度，防止黑图。无法和mixed_precision混合精度共用。
$bucket_reso_steps = 32 #SDXL分桶可以选择32或者64。32更精细分桶。默认为64

#db checkpoint train
$stop_text_encoder_training = 0
$no_token_padding = 0 #不进行分词器填充

#sdxl_db
$diffusers_xformers = 0
$train_text_encoder = 0

# ============= DO NOT MODIFY CONTENTS BELOW | 请勿修改下方内容 =====================
# Activate python venv
.\venv\Scripts\activate

$Env:HF_HOME = "huggingface"
$Env:XFORMERS_FORCE_DISABLE_TRITON = "1"
$network_module="networks.lora"
$ext_args = [System.Collections.ArrayList]::new()
$laungh_script = "train_network"

if ($train_mode -ilike "*db") {
  if ($train_mode -ieq  "db") {
    $laungh_script = "train_db";
    if ($no_token_padding -ne 0) {
      [void]$ext_args.Add("--no_token_padding")
    }
    if ($stop_text_encoder_training) {
      if ($gradient_accumulation_steps){
        $stop_text_encoder_training = $stop_text_encoder_training * $gradient_accumulation_steps
      }
    [void]$ext_args.Add("--stop_text_encoder_training=$stop_text_encoder_training")
    }
  }
  else{
    $laungh_script = "train";
    if ($diffusers_xformers -ne 0) {
      [void]$ext_args.Add("--diffusers_xformers")
    }
    if ($train_text_encoder -ne 0) {
      [void]$ext_args.Add("--train_text_encoder")
    }
  }
  $network_module = ""
  $network_dim = ""
  $network_alpha = ""
  $conv_dim = ""
  $conv_alpha = ""
  $network_weights = ""
  $enable_block_weights = 0
  $enable_block_dim = 0
  $enable_lycoris = 0
  $enable_dylora = 0
  $unet_lr = ""
  $text_encoder_lr = ""
  $train_unet_only = 0
  $train_text_encoder_only = 0
  $training_comment = ""
  $prior_loss_weight = 1
  $network_dropout = "0"
}

if ($train_mode -ilike "sdxl*"){
  $laungh_script = "sdxl_" + $laungh_script
  if ($min_timestep -ne 0) {
    [void]$ext_args.Add("--min_timestep=$min_timestep")
  }
  if ($max_timestep -ne 1000) {
    [void]$ext_args.Add("--max_timestep=$max_timestep")
  }
  if ($cache_text_encoder_outputs -ne 0) { 
    [void]$ext_args.Add("--cache_text_encoder_outputs")
    if ($cache_text_encoder_outputs_to_disk -ne 0) { 
      [void]$ext_args.Add("--cache_text_encoder_outputs_to_disk")
    }
    $shuffle_caption = 0
    $train_unet_only = 1
  }
  if ($no_half_vae -ne 0) { 
    [void]$ext_args.Add("--no_half_vae")
    $mixed_precision = ""
    $full_fp16 = 0
    $full_bf16 = 0
  }
  if ($bucket_reso_steps -ne 64) { 
    [void]$ext_args.Add("--bucket_reso_steps=$bucket_reso_steps")
  }
}

if ($dataset_class) { 
  [void]$ext_args.Add("--dataset_class=$dataset_class")
}
else {
  [void]$ext_args.Add("--train_data_dir=$train_data_dir")
}

if ($vae) {
  [void]$ext_args.Add("--vae=$vae")
}

if ($is_v2_model) {
  [void]$ext_args.Add("--v2")
  $min_snr_gamma = 0
  if ($v_parameterization) {
  [void]$ext_args.Add("--v_parameterization")
  [void]$ext_args.Add("--scale_v_pred_loss_like_noise_pred")
  }
}
else {
  [void]$ext_args.Add("--clip_skip=$clip_skip")
}

if ($prior_loss_weight -and $prior_loss_weight -ne 1) {
  [void]$ext_args.Add("--prior_loss_weight=$prior_loss_weight")
}

if ($network_dim) {
  [void]$ext_args.Add("--network_dim=$network_dim")
}

if ($network_alpha) {
  [void]$ext_args.Add("--network_alpha=$network_alpha")
}

if ($training_comment) {
  [void]$ext_args.Add("--training_comment=$training_comment")
}

if ($persistent_workers) {
  [void]$ext_args.Add("--persistent_data_loader_workers")
}

if ($max_data_loader_n_workers) {
  [void]$ext_args.Add("--max_data_loader_n_workers=$max_data_loader_n_workers")
}

if ($shuffle_caption) {
  [void]$ext_args.Add("--shuffle_caption")
}

if ($weighted_captions) {
  [void]$ext_args.Add("--weighted_captions")
}

if ($cache_latents) { 
  [void]$ext_args.Add("--cache_latents")
  if ($cache_latents_to_disk) {
    [void]$ext_args.Add("--cache_latents_to_disk")
  }
}

if ($output_config) {
  [void]$ext_args.Add("--output_config")
  [void]$ext_args.Add("--config_file=$config_file")
}

if ($gradient_checkpointing) {
  [void]$ext_args.Add("--gradient_checkpointing")
}

if ($save_state -eq 1) {
  [void]$ext_args.Add("--save_state")
}

if ($resume) {
  [void]$ext_args.Add("--resume=$resume")
}

if ($noise_offset) {
  [void]$ext_args.Add("--noise_offset=$noise_offset")
  if ($adaptive_noise_scale) {
    [void]$ext_args.Add("--adaptive_noise_scale=$adaptive_noise_scale")
  }
}
elseif ($multires_noise_iterations) {
  [void]$ext_args.Add("--multires_noise_iterations=$multires_noise_iterations")
  [void]$ext_args.Add("--multires_noise_discount=$multires_noise_discount")
}

if ($network_dropout -ne 0) {
  $enable_lycoris = 0
  [void]$ext_args.Add("--network_dropout=$network_dropout")
  if ($scale_weight_norms -ne 0) { 
    [void]$ext_args.Add("--scale_weight_norms=$scale_weight_norms")
  }
  if ($enable_dylora -ne 0) {
  [void]$ext_args.Add("--network_args")
    if ($rank_dropout) {
      [void]$ext_args.Add("rank_dropout=$rank_dropout")
    }
    if ($module_dropout) {
      [void]$ext_args.Add("module_dropout=$module_dropout")
    }
  }
}

if ($enable_block_weights) {
  $enable_dylora = 0
  $enable_lycoris = 0
  [void]$ext_args.Add("--network_args")
  [void]$ext_args.Add("down_lr_weight=$down_lr_weight")
  [void]$ext_args.Add("mid_lr_weight=$mid_lr_weight")
  [void]$ext_args.Add("up_lr_weight=$up_lr_weight")
  [void]$ext_args.Add("block_lr_zero_threshold=$block_lr_zero_threshold")
  if ($enable_block_dim) {
    [void]$ext_args.Add("block_dims=$block_dims")
    [void]$ext_args.Add("block_alphas=$block_alphas")
    if ($conv_block_dims){
    [void]$ext_args.Add("conv_block_dims=$conv_block_dims")
      if ($conv_block_alphas){
         [void]$ext_args.Add("conv_block_alphas=$conv_block_alphas")
      }
    }
    elseif ($conv_dim){
    [void]$ext_args.Add("conv_dim=$conv_dim")
      if ($conv_alpha){
        [void]$ext_args.Add("conv_alpha=$conv_alpha")
      }
    }
  }
}
elseif ($enable_lycoris) {
  $enable_dylora = 0
  [void]$ext_args.Add("--network_module=lycoris.kohya")
  [void]$ext_args.Add("--network_args")
  if ($conv_dim){
    [void]$ext_args.Add("conv_dim=$conv_dim")
      if ($conv_alpha){
        [void]$ext_args.Add("conv_alpha=$conv_alpha")
    }
  }
  if ($dropout) {
    [void]$ext_args.Add("dropout=$dropout")
  }
  [void]$ext_args.Add("algo=$algo")
}
elseif ($enable_dylora) {
  [void]$ext_args.Add("--network_module=networks.dylora")
  [void]$ext_args.Add("--network_args")
  [void]$ext_args.Add("unit=$unit")
  if ($conv_dim){
    [void]$ext_args.Add("conv_dim=$conv_dim")
      if ($conv_alpha){
        [void]$ext_args.Add("conv_alpha=$conv_alpha")
    }
  }
  if ($module_dropout) {
      [void]$ext_args.Add("module_dropout=$module_dropout")
  }
}
else {
  if ($conv_dim){
    [void]$ext_args.Add("--network_args")
    [void]$ext_args.Add("conv_dim=$conv_dim")
      if ($conv_alpha){
        [void]$ext_args.Add("conv_alpha=$conv_alpha")
    }
  }
}

if($optimizer_type -ieq "adafactor"){
	[void]$ext_args.Add("--optimizer_type=$optimizer_type")
	[void]$ext_args.Add("--optimizer_args")
	[void]$ext_args.Add("scale_parameter=True")
  [void]$ext_args.Add("warmup_init=True")
  $lr_warmup_steps=0
}

if($optimizer_type -ilike "DAdapt*"){
  [void]$ext_args.Add("--optimizer_type=$optimizer_type")
  [void]$ext_args.Add("--optimizer_args")
  [void]$ext_args.Add("weight_decay=0.01")
  if($optimizer_type -ieq "DAdaptation" -or $optimizer_type -ilike "DAdaptAdam*"){
    [void]$ext_args.Add("decouple=True")
    if ($optimizer_type -ieq "DAdaptAdam") {
        [void]$ext_args.Add("use_bias_correction=True")
      }
  }
  $lr = "1"
  if ($unet_lr) {
    $unet_lr = $lr
  }
  if ($text_encoder_lr) {
    $text_encoder_lr = $lr
  }
}

if($optimizer_type -ieq "Lion" -or $optimizer_type -ieq "Lion8bit" -or $optimizer_type -ieq "PagedLion8bit"){
	[void]$ext_args.Add("--optimizer_type=$optimizer_type")
	[void]$ext_args.Add("--optimizer_args")
  [void]$ext_args.Add("weight_decay=0.01")
  [void]$ext_args.Add("betas=.95,.98")
}

if($optimizer_type -ieq "AdamW8bit"){
	$optimizer_type=""
	[void]$ext_args.Add("--use_8bit_adam")
}

if($optimizer_type -ieq "PagedAdamW8bit"){
  [void]$ext_args.Add("--optimizer_type=$optimizer_type")
  [void]$ext_args.Add("--optimizer_args")
  [void]$ext_args.Add("weight_decay=0.01")
}

if($optimizer_type -ieq "Sophia") {
  [void]$ext_args.Add("--optimizer_type=pytorch_optimizer.SophiaH")
  [void]$ext_args.Add("--optimizer_args")
  [void]$ext_args.Add("weight_decay=0.01")
}

if($optimizer_type -ieq "Prodigy") {
  [void]$ext_args.Add("--optimizer_type=$optimizer_type")
  [void]$ext_args.Add("--optimizer_args")
  [void]$ext_args.Add("weight_decay=0.01")
  [void]$ext_args.Add("decouple=True")
  [void]$ext_args.Add("use_bias_correction=True")
  [void]$ext_args.Add("d_coef=$d_coef")
  if($lr_warmup_steps){
    [void]$ext_args.Add("safeguard_warmup=True")
  }
  if($d0){
    [void]$ext_args.Add("d0=$d0")
  }
  $lr = "1"
  if ($unet_lr) {
    $unet_lr = $lr
  }
  if ($text_encoder_lr) {
    $text_encoder_lr = $lr
  }
}

if($optimizer_type -ieq "Adan") {
  [void]$ext_args.Add("--optimizer_type=pytorch_optimizer.Adan")
  #[void]$ext_args.Add("--optimizer_args")
  #[void]$ext_args.Add("weight_decay=2e-5")
  #[void]$ext_args.Add("max_grad_norm=5.0")
  #[void]$ext_args.Add("adanorm=true")
}

if($optimizer_type -ieq "Tiger") {
  [void]$ext_args.Add("--optimizer_type=pytorch_optimizer.Tiger")
  [void]$ext_args.Add("--optimizer_args")
  [void]$ext_args.Add("weight_decay=0.01")
}

if ($unet_lr) {
  if ($train_unet_only) {
    $train_text_encoder_only=0
    [void]$ext_args.Add("--network_train_unet_only")
  }
  [void]$ext_args.Add("--unet_lr=$unet_lr")
}

if ($text_encoder_lr) {
  if ($train_text_encoder_only) {
    [void]$ext_args.Add("--network_train_text_encoder_only")
  }
  [void]$ext_args.Add("--text_encoder_lr=$text_encoder_lr")
}

if ($network_weights) {
  [void]$ext_args.Add("--network_weights=$network_weights")
}

if ($reg_data_dir) {
  [void]$ext_args.Add("--reg_data_dir=$reg_data_dir")
}

if ($keep_tokens) {
  [void]$ext_args.Add("--keep_tokens=$keep_tokens")
}

if ($min_snr_gamma) {
  [void]$ext_args.Add("--min_snr_gamma=$min_snr_gamma")
}

if ($wandb_api_key) {
  [void]$ext_args.Add("--wandb_api_key=$wandb_api_key")
  [void]$ext_args.Add("--log_with=wandb")
  [void]$ext_args.Add("--log_tracker_name=" +$output_name)
}

if ($enable_sample) {
  [void]$ext_args.Add("--sample_every_n_epochs=$sample_every_n_epochs")
  [void]$ext_args.Add("--sample_prompts=$sample_prompts")
  [void]$ext_args.Add("--sample_sampler=$sample_sampler")
}

if ($lr_scheduler_num_cycles) {
  [void]$ext_args.Add("--lr_scheduler_num_cycles=$lr_scheduler_num_cycles")
}

if ($base_weights) {
  [void]$ext_args.Add("--base_weights")
  foreach ($base_weight in $base_weights.Split(" ")) {
    [void]$ext_args.Add($base_weight)
  }
  [void]$ext_args.Add("--base_weights_multiplier")
  foreach ($ratio in $base_weights_multiplier.Split(" ")) {
    [void]$ext_args.Add([float]$ratio)
  }
}

if ($enable_bucket) {
  [void]$ext_args.Add("--enable_bucket")
  [void]$ext_args.Add("--min_bucket_reso=$min_bucket_reso")
  [void]$ext_args.Add("--max_bucket_reso=$max_bucket_reso")
}


if($full_fp16 -ne 0){
  [void]$ext_args.Add("--full_fp16")
  $mixed_precision = "fp16"
  $save_precision = "fp16"
}
elseif($full_bf16 -ne 0){
  [void]$ext_args.Add("--full_bf16")
  $mixed_precision = "bf16"
  $save_precision = "bf16"
}

if ($mixed_precision) {
  [void]$ext_args.Add("--mixed_precision=$mixed_precision")
}

if ($network_module) {
  [void]$ext_args.Add("--network_module=$network_module")
}

if ($gradient_accumulation_steps) {
  [void]$ext_args.Add("--gradient_accumulation_steps=$gradient_accumulation_steps")
}

if ($lr_warmup_steps) {
  if ($gradient_accumulation_steps){
    $lr_warmup_steps = $lr_warmup_steps * $gradient_accumulation_steps
  }
  [void]$ext_args.Add("--lr_warmup_steps=$lr_warmup_steps")
}

# run train
accelerate launch --num_cpu_threads_per_process=8 "./sd-scripts/$laungh_script.py" `
  --pretrained_model_name_or_path=$pretrained_model `
  --output_dir="./output" `
  --logging_dir="./logs" `
  --resolution=$resolution `
  --max_train_epochs=$max_train_epoches `
  --learning_rate=$lr `
  --lr_scheduler=$lr_scheduler `
  --output_name=$output_name `
  --train_batch_size=$batch_size `
  --save_every_n_epochs=$save_every_n_epochs `
  --save_precision=$save_precision `
  --seed=$seed  `
  --max_token_length=225 `
  --caption_extension=".txt" `
  --save_model_as=$save_model_as `
  --vae_batch_size=$vae_batch_size `
  --xformers $ext_args

Write-Output "Train finished"
Read-Host | Out-Null ;