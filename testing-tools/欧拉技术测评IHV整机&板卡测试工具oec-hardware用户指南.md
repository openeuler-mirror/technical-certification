目录

[1 简介](#简介)

[2 环境要求](#环境要求)

[3 重要说明](#重要说明)

[4 工具安装](#工具安装)

[5 测试执行](#测试执行)


# 简介
为解决欧拉技术测评过程中涉及的整机和板卡兼容性测试问题，特基于[《欧拉技术测评兼容性测试用例（整机&板卡）》](../testing-standard/欧拉技术测评兼容性测试用例（整机&板卡）.md) 集成了oec-hardware测试工具。
此工具将根据《欧拉技术测评兼容性测试用例（整机&板卡）》提取为27个自动化测试用例，分为整机测试用例集和板卡测试用例集

# 环境要求
|   项目    |                       要求                    |
|-----------|---------------------------------------------|
|    硬件   | 当前支持Kunpeng和X86底座，有其他平台的适配需求欢迎提交issue   |
|  操作系统  |               openEuler系操作系统            |


# 重要说明
1. 部分测试用例会重启机器，请勿在生产环境安装和执行测试工具。
2. 工具安装过程需要从外网下载代码和依赖包，请确保网络连接（如不通外网，需要下载相关依赖并进行安装）。
3. 工具默认日志存放在/usr/share，请确保目录剩余空间足够。

# 工具安装
## 步骤1. 依赖安装
    
    yum install -y fio net-tools qperf
    wget https://gitee.com/cuixucui/oech-ci-rpm/raw/master/memtester-4.3.0-18.fc33.aarch64.rpm
    rpm -ivh memtester-4.3.0-18.fc33.aarch64.rpm
## 步骤2. 获取工具安装包

    wget https://gitee.com/spring_view/oec-hardware-rpm/raw/master/oec-hardware-1.0.0-2.aarch64.rpm
如果是X86的服务器，请下载 https://gitee.com/spring_view/oec-hardware-rpm/blob/master/oec-hardware-1.0.0-2.x86_64.rpm

## 步骤2. 安装oec-hardware。

    rpm -ivh oec-hardware-1.0.0-2.aarch64.rpm

### -- 结束

# 测试执行
## 步骤1. 执行测试。

部分用例需要root权限，请使用root用户执行。

    oech 

## 步骤2.查看结果日志

    查看工具的操作日志，工具的详细操作日志，路径为“/usr/share/oech/logs/oech-yyyymmddxxxx-xxxxxxx.tar”

### -- 结束
