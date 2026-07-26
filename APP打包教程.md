# 📱 人生五册 APP — 手机打包 APK 教程

## 方案一：Codemagic 在线编译（推荐，全程手机操作）

### 准备工作
你只需要：一个 GitHub 账号（没有就注册一个，免费的）

### 步骤

#### 第1步：注册 GitHub 账号
- 手机浏览器打开 https://github.com
- 点 Sign up，按提示注册

#### 第2步：创建仓库并上传代码
- 在 GitHub 点右上角 **+** → **New repository**
- 仓库名填 `life-books`，选 Public
- 点 **creating a new file**
- 文件名填 `code.tar.gz`
- 把上面那个 `life_books_v5_ready.tar.gz` 上传上去
- 或者直接用手机浏览器上传项目里的每个文件

**更简单的方式：** 用手机浏览器打开 https://github.com/new ，创建空仓库后，点 **uploading an existing file**，把代码压缩包传上去。

#### 第3步：注册 Codemagic
- 手机浏览器打开 https://codemagic.io
- 点 **Get started for free**
- 用 GitHub 账号登录

#### 第4步：连接仓库
- 点 **Add application**
- 选择你刚才创建的 `life-books` 仓库
- 选择 **Flutter** 作为框架

#### 第5步：配置并构建
- Build platform 选 **Android**
- 点 **Start build**
- 等 5-10 分钟
- 构建完成后下载 APK 文件

#### 第6步：安装到手机
- 把下载的 APK 传到手机
- 打开安装即可（需要允许"安装未知来源应用"）

---

## 方案二：用电脑编译（3条命令）

如果你有电脑，其实也很快：

### 准备工作
1. 安装 Flutter SDK：https://flutter.dev/docs/get-started/install
2. 安装 Android Studio：https://developer.android.com/studio

### 步骤
```bash
# 1. 解压项目
tar xzf life_books_v5_ready.tar.gz
cd life_books

# 2. 安装依赖
flutter pub get

# 3. 编译 APK
flutter build apk --release
```

编译好的 APK 在：`build/app/outputs/flutter-apk/app-release.apk`
传到手机安装即可。

---

## 项目文件说明

- **APP名称：** 人生五册
- **包名：** com.zheergen.life_books
- **最低系统：** Android 5.0+（覆盖 99% 的安卓手机）
- **当前版本：** V5 纯离线版（无需联网，数据存在手机本地）
- **大小：** 预计 APK 约 15-25MB

## 功能清单
✅ 五册完整功能（家人册/学习册/生活册/工作册/人生三鉴）
✅ 新增/编辑/删除记录
✅ 离线数据存储（Hive 本地数据库）
✅ 搜索功能
✅ 下拉刷新
✅ 空状态提示
✅ 时间轴视图
✅ 跨册记录聚合
✅ 网络状态检测
✅ 设置页面
✅ 登录页（本地模式）
