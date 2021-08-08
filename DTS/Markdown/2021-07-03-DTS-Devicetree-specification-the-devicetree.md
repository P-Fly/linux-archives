# 基本概念

## 简介

 - **DTS** 指定一个被称为 **Devicetree** 的结构来描述系统硬件。

 - 引导程序将 **Devicetree** 载入到客户端程序的内存中，并且将 **Devicetree** 的指针传递给客户端程序。

 - **Devicetree** 是一种树形结构，每个节点使用 **Property/Value** 表示设备的特性。

 - **Devicetree** 描述系统中不能被动态探测到的设备信息。

![Devicetree Example][1]

## 结构和惯例

### 节点名

每个节点在 **Devicetree** 中都有一个名字，其标准格式为：

```
node-name@unit-address
```

 1. **node-name** 用于指定节点对应的设备类型：

    - 长度为1至31个字符。

    - 由下表中的字符组成。

        ![Valid Characters For Node Names][2]

    - 以小写或大写字符开始，并描述设备的通用类别。

 2. **unit-address** 用于指定节点与总线的关系，一般为节点在总线上的位置：

    - 由上表中的字符组成。

    - 该值特定于节点所在的总线类型。即对于不同总线，其含义可能不同。

        - 对于 **memory** 节点，**unit-address** 为其在虚拟空间中的首地址。

            ```
            memory@60000000 {
                device_type = "memory";
                reg = <0x60000000 0x40000000>;
            };
            ```

        - 对于 **CPU** 节点，**unit-address** 为由0开始的索引值。

            ```
            cpu@0 {
                device_type = "cpu";
                compatible = "arm,cortex-a9";
            };
            ```

    - 该值必须与节点 **reg** 属性中的第一个地址匹配。如果该节点没有 **reg** 属性，则必须省略 **unit-address**。

 3. 根节点：

    - 根节点没有 **node-name** 和 **unit-address**，通过 **/** 进行标识。

### 通用名称

|   |   |   |   |
|:-:|:-:|:-:|:-:|
| adc              | endpoint             | magnetometer      | rng                |
| accelerometer    | ethernet             | mailbox           | rtc                |
| atm              | ethernet-phy         | mdio              | sata               |
| audio-codec      | fdc                  | memory            | scsi               |
| audio-controller | flash                | memory-controller | serial             |
| backlight        | gnss                 | mmc               | sound              |
| bluetooth        | gpio                 | mmc-slot          | spi                |
| bus              | gpu                  | mouse             | sram-controller    |
| cache-controller | gyrometer            | nand-controller   | ssi-controller     |
| camera           | hdmi                 | nvram             | syscon             |
| can              | hwlock               | oscillator        | temperature-sensor |
| charger          | i2c                  | parallel          | timer              |
| clock            | i2c-mux              | pc-card           | touchscreen        |
| clock-controller | ide                  | pci               | tpm                |
| compact-flash    | interrupt-controller | pcie              | usb                |
| cpu              | iommu                | phy               | usb-hub            |
| cpus             | isa                  | pinctrl           | usb-phy            |
| crypto           | keyboard             | pmic              | video-codec        |
| disk             | key                  | pmu               | vme                |
| display          | keys                 | port              | watchdog           |
| dma-controller   | lcd-controller       | ports             |                    |
| dsi              | led                  | power-monitor     |                    |
| dsp              | leds                 | pwm               |                    |
| eeprom           | led-controller       | regulator         |                    |
| efuse            | light-sensor         | reset-controller  |                    |

### 路径名

通过从根节点到指定节点的完整路径，可以唯一标识设备树中的节点。比如：

```
/node-name-1/node-name-2/node-name-N

/cpus/cpu@1
```

### 属性

**Devicetree** 使用属性描述设备的特性，属性包含 **属性名** 和 **属性值**。

#### 属性名

 - 长度为1至31个字符。

 - 由下表中的字符组成。

    ![Valid Characters For Property Names][3]

 - 非标准属性名应该指定一个独特的字符串作为前缀，例如定义该属性的公司或组织的名称。

    ```
    fsl,channel-fifo-len
    ibm,ppc-interrupt-server#s
    linux,network-index
    ```

#### 属性值

 - 属性值是由包含属性相关联的信息的0个或多个字节组成的数组。

 - 属性可以为空值，通过该属性是否存在表示 **ture** 或者 **false**。

 1. **empty**

    如果属性值的类型是空，那么属性名是否存在于节点中就代表 **true** 或 **false**。

    ```
    v2m_mmc_gpios: gpio@48 {
        compatible = "arm,vexpress-sysreg,sys_mci";
        reg = <0x048 4>;
        gpio-controller;
        #gpio-cells = <2>;
    };
    ```

    对于上面的例子，**gpio-controller** 的属性值就是 **true**。

 2. **u32**

    表示一个以 **大端模式** 存储的 **32Bit** 的整数。

    ```
    #address-cells = <1>;
    #size-cells = <1>;

    memory@60000000 {
        device_type = "memory";
        reg = <0x60000000 0x40000000>;
    };
    ```

    在上面的例子中，内存 **addr** 和 **size** 属性的类型为 **u32**，其属性值分别为 **0x60000000** 和 **0x40000000**。

 3. **u64**

    表示一个以 **大端模式** 存储的 **64Bit** 的整数。其值由两个 **u32** 类型构成，第一个值存储 **MSB** 部分，第二个值存储 **LSB** 部分。

    ```
    #address-cells = <2>;
    #size-cells = <2>;

    memory@80000000 {
        device_type = "memory";
        reg = <0 0x80000000 0 0x80000000>;
    };
    ```

    在上面的例子中，内存 **addr** 和 **size** 属性的类型为 **u64**，其属性值分别为 **0x0000000080000000** 和 **0x0000000080000000**。

 4. **string**

    表示一个可打印，并以 **\0** 结尾的字符串。

    ```
    #address-cells = <1>;
    #size-cells = <1>;

    memory@60000000 {
        device_type = "memory";
        reg = <0x60000000 0x40000000>;
    };
    ```

    在上面的例子中，**device_type** 的属性值为 **memory**。

 5. **prop-encoded-array**

    表示一种混合类型，其属性值中含有多种属性。

    ```
    leds {
        compatible = "gpio-leds";

        user1 {
            label = "v2m:green:user1";
            gpios = <&v2m_led_gpios 0 0>;
            linux,default-trigger = "heartbeat";
        };
    };
    ```

    在上面的例子中，**gpios** 属性的类型为 **prop-encoded-array**，由 **u32** 与 **phandle** 类型组成。

 6. **phandle**

    一个 **u32** 的值。该值用于引用 **Devicetree** 中的其它节点。任何可引用的节点都可以定义为一个唯一的 **u32** 的值。

    ```
    memory-controller@100e0000 {
        compatible = "arm,pl341", "arm,primecell";
        reg = <0x100e0000 0x1000>;
        clocks = <&oscclk2>;
        clock-names = "apb_pclk";
    };
    ```

    在上面的例子中，**clocks** 属性的类型为 **phandle**，其指向 **oscclk2** 节点。

 7. **stringlist**

    由一连串的 **string** 构成的字符串表。

    ```
    memory-controller@100e0000 {
        compatible = "arm,pl341", "arm,primecell";
        reg = <0x100e0000 0x1000>;
        clocks = <&oscclk2>;
        clock-names = "apb_pclk";
    };
    ```

    在上面的例子中，**compatible** 属性的类型为 **stringlist**，由两个 **string** 组成。

## 标准属性

### compatible

属性值类型为 **stringlist**：

 - 该属性值由一个或多个字符串组成，用于定义这个设备的编程模型。

 - 客户端程序使用此字符串列表选择对应的设备驱动程序。

 - 单个设备驱动程序可以匹配多个设备。

 - 推荐的格式为：**manufacturer,model**。其中 **manufacturer** 为制造商名称，**model**为设备型号。

```
compatible = "fsl,mpc8641", "ns16550";
```

### model

属性值类型为 **string**：

用于指定设备制造商的型号。

```
model = "fsl,MPC8349EMITX";
```

### phandle

属性值类型为 **u32**：

在 **Devicetree** 中指定一个唯一的数字标识符，该值可以被其它关联节点所引用。

 - 老版本的客户端程序可能遇到 **不推荐** 的属性格式 **linux,phandle**。为了兼容性，客户端程序可能同时支持 **linux,phandle** 和 **phandle**，这两个属性的含义和使用方法都是相同的。

 - 大部分 **Devicetree** 不会显示的包含 **phandle** 属性。当 **DTC** 工具将 **DTS** 编译为 **DTB**，且其他节点通过 **phandle** 类型的属性引用了该节点时，该节点会自动插入 **phandle** 属性。

```
pic@10000000 {
    phandle = <1>;
    interrupt-controller;
};

another-device-node {
    interrupt-parent = <1>;
};
```

### status

属性值类型为 **string**：

有效值如下：

 - **okay：** 指示设备节点对应的设备是可以使用的。

 - **disabled：** 指示设备节点目前不可以运行，但将来可能会运行（Not Plug In Or Switched Off）。

 - **reserved：** 指示设备节点可以运行，但不应该被使用。比如：设备被其它软件组件控制。

 - **fail：** 指示设备节点无法运行，在设备上检测到一个必须修复的严重错误。

 - **fail-sss：** 与 **fail** 相同。**sss** 用于指定错误的值。

### \#address-cells and \#size-cells

属性值类型为 **u32**：

 - 属性值作用于子节点，用于描述子节点如何寻址。

 - **\#address-cells**：在子节点 **reg** 属性中，由多少个 **u32** 单元形成 **address** 段。

 - **\#size-cells**：在子节点 **reg** 属性中，由多少个**u32** 单元形成 **length** 段。

 - 该组属性没有继承性，即不从父节点处继承，而应该显示定义。

 - 如果没有定义该组属性，那么其默认值为 **\#address-cells = 2**，**\#size-cells = 1**。

```
#address-cells = <1>;
#size-cells = <1>;

memory@60000000 {
    device_type = "memory";
    reg = <0x60000000 0x40000000>;
};
```

### reg

属性值类型为 **prop-encoded-array**，由任意数量的 **<address, length>** 域构成：

 - 用于描述该设备在父总线地址空间内的地址范围。

 - 该属性通常代表 **memory-mapped IO** 寄存器块的偏移和长度，但在某些总线类型上可能有不同的含义。

 - 由父节点中的 **\#address-cells** 和 **\#size-cells** 指定 **<address, length>** 所需的单元格数。

 - 如果 **\#size-cells = 0**，则在该属性中省略 **length** 字段。

```
#address-cells = <1>;
#size-cells = <1>;

memory@60000000 {
    device_type = "memory";
    reg = <0x60000000 0x40000000>;
};
```

### virtual-reg

属性值类型为 **u32**：

指定一个有效的虚拟地址，映射到 **reg** 属性的首个物理地址中。

### ranges

属性值类型为 **empty** 或 **prop-encoded-array**：

该属性提供总线地址空间和父地址空间之间的映射或转换的方法。

 - 当属性值为 **empty** 时，表明父节点和子节点的地址空间相同，不需要地址转换。

 - 当属性值为 **prop-encoded-array** 时，由任意数量的三元组 **<child-bus-address, parent-bus-address, length>** 构成。

    - **child-bus-address** 是 **子节点** 地址空间中的物理地址，其包含的 **u32** 的数量由 **该节点** 的 **\#address-cells** 属性决定。

    - **parent-bus-address** 是 **父节点** 地址空间中的物理地址，其包含的 **u32** 的数量由 **父节点** 的 **\#address-cells** 属性决定。

    - **length** 指定了 **子节点** 地址空间的长度，其包含的 **u32** 的数量由 **该节点** 的 **\#size-cells** 属性决定。

 - 如果该属性不存在，则表示父节点和子节点之间不存在地址映射。

```
#address-cells = <2>;
#size-cells = <2>;

cci@2c090000 {
    compatible = "arm,cci-400";
    #address-cells = <1>;
    #size-cells = <1>;
    reg = <0 0x2c090000 0 0x1000>;
    ranges = <0x0 0x0 0x2c090000 0x10000>;

    cci_control1: slave-if@4000 {
        compatible = "arm,cci-400-ctrl-if";
        interface-type = "ace";
        reg = <0x4000 0x1000>;
    };
```

例子中，**cci** 节点包含了 **ranges** 属性，其属性值为 **<0x0 0x0 0x2c090000 0x10000>**。表示为 **子节点** 地址空间的物理地址 **0x00** 映射到 **父节点** 地址空间的物理地址 **0x000000002c090000** 处。因此 **cci_control1** 在 **父节点** 地址空间的物理地址为 **0x000000002c090000 + 0x4000 = 0x000000002c094000**。

### dma-ranges

与 **ranges** 属性的含义几乎一致，只是描述的地址空间为 **DMA** 空间。

 [1]: ./images/Devicetree_Example.PNG
 [2]: ./images/Valid_Characters_For_Node_Names.PNG
 [3]: ./images/Valid_Characters_For_Property_Names.PNG

