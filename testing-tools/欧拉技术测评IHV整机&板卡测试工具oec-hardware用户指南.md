目录

[1 简介](#简介)

[2 环境要求](#环境要求)

[3 重要说明](#重要说明)

[4 工具安装](#工具安装)

[5 测试执行](#测试执行)


# 简介

为解决欧拉技术测评过程中涉及的整机和板卡兼容性测试问题，特基于[《欧拉技术测评兼容性测试用例（整机&板卡）》](../testing-standard/欧拉技术测评兼容性测试用例（整机&板卡）.md) 集成了oec-hardware测试工具。
此工具将根据《欧拉技术测评兼容性测试用例（整机&板卡）》提取为58个自动化测试用例，分为整机测试用例集和板卡测试用例集

# 环境要求

## 整机测试环境要求

|   项目    |                       要求                    |
|-----------|---------------------------------------------|
|    整机数量   | 需要两台整机，业务网口互通   |
|    硬件   | 至少有一张RAID卡和一张网卡（包括集成主板硬件)   |
|    内存   | 建议满配   |
|  操作系统  |               openEuler系操作系统（支持dnf/yum/pip3)           |

## 板卡测试环境要求

|   项目    |                       要求                    |
|-----------|---------------------------------------------|
|    服务器型号   | Taishan200(Model 2280)、2288H V5或同等类型的服务器，对于x86_64服务器，icelake/cooperlake/cascade可任选一种，优选icelake   |
|    RAID卡   | 需要组raid，至少组raid0   |
|    NIC/IB卡   | 服务端和测试端需要分别插入一张同类型板卡，配置同网段IP，保证直连互通  |
|    FC卡   | 需要连接磁阵，至少组两个lun   |
|  操作系统  |               openEuler系操作系统（支持dnf/yum/pip3)            |


# 重要说明

1. 部分测试用例会重启机器，请勿在生产环境安装和执行测试工具。

2. 工具安装过程需要从外网下载代码和依赖包，请确保网络连接（如不通外网，需要下载相关依赖并进行安装）。

3. 工具日志默认存放在/usr/share，请确保目录剩余空间足够。

4. 如果要测试外部驱动，请提前安装驱动，配置测试环境。

   GPU、VGPU、keycard等测试项需要提前安装外部驱动，保证环境部署完成，然后使用本工具进行测试。

# 芯片验证说明

芯片验证和测试的流程如下：

![](docs/芯片验证流程图.png)

1. 芯片使能测试前，请确认工具支持测试该类型的芯片；如果工具不支持，请联系openEuler兼容性sig组 oecompatibility@openeuler.org 联合制定测试标准，在工具中集成测试用例；

2. 工具默认测试内核驱动，如果需要测试外部驱动，请自行安装部署驱动；

3. 测试环境准备完毕，安装测试工具，执行测试。

# 离线安装环境部署要求

1. 下载 openEuler 官方的 everything iso，挂载本地 repo 源。

   如果在 everything iso 中无法找到依赖的软件包，请手动从 [openEuler 官方 repo](https://repo.openeuler.org/) 中下载软件包，上传至测试机中进行安装。

2. 根部不同的测试项，配置离线测试依赖

   | 测试项 | 文件名 | 路径 |
   | ---- | ----- | ----- |
   | kabi | 下载对应版本和架构的内核白名单，此处以openEuler 22.03LTS、aarch64为例：https://gitee.com/src-openeuler/kernel/blob/openEuler-22.03-LTS/kabi_whitelist_aarch64 | `/var/oech` |
   | GPU  | https://github.com/wilicc/gpu-burn | `/opt` |
   |      | https://github.com/NVIDIA/cuda-samples/archive/refs/heads/master.zip | `/opt` |
   | VGPU | nvidia vgpu client驱动软件包 | /root |
   |      | 下载对应版本和架构的虚拟机镜像文件，此处以openEuler 22.03LTS、x86_64为例：https://repo.openeuler.org/openEuler-22.03-LTS/virtual_machine_img/x86_64/openEuler-22.03-LTS-x86_64.qcow2.xz | `/opt` |


# 工具安装

## 安装过程

### 客户端

1. 配置 [openEuler 官方 repo](https://repo.openeuler.org/) 中对应版本的 everything 和 update 源，使用 `dnf` 安装客户端 oec-hardware。

   ```
   dnf install oec-hardware
   ```

2. 输入 `oech` 命令，可正常运行，则表示安装成功。

### 服务端

1. 使用 `dnf` 安装服务端 oec-hardware-server。

   ```
   dnf install oec-hardware-server
   ```

2. 启动服务。本服务通过搭配 nginx 服务提供 web 服务，默认使用 80 端口，可以通过 nginx 服务配置文件修改对外端口，启动前请保证这些端口未被占用。

   ```
   systemctl start oech-server.service
   systemctl start nginx.service
   ```

3. 关闭防火墙和 SElinux。

   ```
   systemctl stop firewalld
   iptables -F
   setenforce 0
   ```

# 测试执行

## 前提条件

* `/usr/share/oech/kernelrelease.json` 文件中列出了当前支持的所有系统版本，使用`uname -a` 命令确认当前系统内核版本是否属于框架支持的版本。

* 框架默认会扫描所有网卡，对网卡进行测试前，请自行筛选被测网卡，并给它配上能 `ping` 通服务端的 ip；如果客户端是对 InfiniBand 网卡进行测试，服务端也必须有一个 InfiniBand 网卡并提前配好 ip 。建议不要使用业务网口进行网卡测试。

* `/usr/share/oech/lib/config/test_config.yaml ` 是硬件测试项配置文件模板，`fc`、`raid`、`disk`、`ethernet`、`infiniband`硬件测试前需先根据实际环境进行修改，其它硬件测试不需要修改。

## 使用步骤

1. 在客户端启动测试框架。在客户端启动 `oech`，填写`ID`、`URL`、`Server`配置项，`ID` 建议填写 gitee 上的 issue ID（注意：`ID`中不能带特殊字符）；`URL`建议填写产品链接；`Server` 必须填写为客户端可以直接访问的服务器域名或 ip，用于展示测试报告和作网络测试的服务端。服务端`nginx`默认端口号是`80`，如果服务端安装完成后没有修改该端口，`Compatibility Test Server` 的值只需要输入服务端的业务IP地址；否则需要带上端口号，比如：`172.167.145.2:90`。

   ```
   # oech
   The openEuler Hardware Compatibility Test Suite
   Please provide your Compatibility Test ID:
   Please provide your Product URL:
   Please provide the Compatibility Test Server (Hostname or Ipaddr):
   ```

2. 进入测试套选择界面。在用例选择界面，框架将自动扫描硬件并选取当前环境可供测试的测试套，输入 `edit` 可以进入测试套选择界面。

   ```
   These tests are recommended to complete the compatibility test: 
   No. Run-Now?  status    Class         Device         driverName     driverVersion     chipModel           boardModel
   1     yes     NotRun    acpi                                                                              
   2     yes     NotRun    clock                                                                             
   3     yes     NotRun    cpufreq                                                                           
   4     yes     NotRun    disk                                                                              
   5     yes     NotRun    ethernet      enp3s0         hinic          2.3.2.17          Hi1822              SP580
   6     yes     NotRun    ethernet      enp4s0         hinic          2.3.2.17          Hi1822              SP580
   7     yes     NotRun    ethernet      enp125s0f0     hns3                             HNS GE/10GE/25GE    TM210/TM280
   8     yes     NotRun    ethernet      enp125s0f1     hns3                             HNS GE/10GE/25GE    TM210/TM280
   9     yes     NotRun    ipmi                                                                              
   10    yes     NotRun    kabi                                                                              
   11    yes     NotRun    kdump                                                                             
   12    yes     NotRun    memory                                                                            
   13    yes     NotRun    perf                                                                              
   14    yes     NotRun    system                                                                            
   15    yes     NotRun    usb                                                                               
   16    yes     NotRun    watchdog                                                      
   Ready to begin testing? (run|edit|quit)
   ```

3. 选择测试套。`all|none` 分别用于 `全选|全取消`（必测项 `system` 不可取消，多次执行成功后 `system` 的状态会变为`Force`）；数字编号可选择测试套，每次只能选择一个数字，按回车符之后 `no` 变为 `yes`，表示已选择该测试套。

   ```
   Select tests to run:
   No. Run-Now?  status    Class         Device         driverName     driverVersion     chipModel           boardModel
   1     no      NotRun    acpi                                                                              
   2     no      NotRun    clock                                                                             
   3     no      NotRun    cpufreq                                                                           
   4     no      NotRun    disk                                                                              
   5     yes     NotRun    ethernet      enp3s0         hinic          2.3.2.17          Hi1822              SP580
   6     no      NotRun    ethernet      enp4s0         hinic          2.3.2.17          Hi1822              SP580
   7     no      NotRun    ethernet      enp125s0f0     hns3                             HNS GE/10GE/25GE    TM210/TM280
   8     no      NotRun    ethernet      enp125s0f1     hns3                             HNS GE/10GE/25GE    TM210/TM280
   9     no      NotRun    ipmi                                                                              
   10    no      NotRun    kabi                                                                              
   11    no      NotRun    kdump                                                                             
   12    no      NotRun    memory                                                                            
   13    no      NotRun    perf                                                                              
   14    yes     NotRun    system                                                                            
   15    no      NotRun    usb                                                                               
   16    no      NotRun    watchdog     
   Selection (<number>|all|none|quit|run):
   ```

4. 开始测试。选择完成后输入 `run` 开始测试。

5. 上传测试结果。测试完成后可以上传测试结果到服务器，便于结果展示和日志分析。如果上传失败，请检查网络配置，然后重新上传测试结果。

   ```
   ...
   -------------  Summary  -------------
   ethernet-enp3s0                  PASS
   system                           PASS
   Log saved to /usr/share/oech/logs/oech-20200228210118-TnvUJxFb50.tar succ.
   Do you want to submit last result? (y|n) y
   Uploading...
   Successfully uploaded result to server X.X.X.X.
   ```

6. 查看工具的测试日志
   
   客户端详细的测试日志路径为 `/usr/share/oech/logs/oech-yyyymmddxxxx-xxxxxxx.tar` 。

7. 查看测试结果。

   测试结果上传到服务端后，在浏览器打开服务端 IP 地址，点击导航栏 `Results` 界面，找到对应的测试 id 进入，可以看到具体的测试结果展示，包括环境信息和执行结果等。
