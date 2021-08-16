# 设备节点的要求

## 基本设备节点类型

**Devicetree** 需要有一个 **root** 节点和下列两个处于 **root** 中的节点：

 - 一个 **/cpus** 节点。

 - 至少一个 **/memory** 节点。

## root 节点

**Devicetree** 有一个单个根节点，其他所有设备节点都是其后代。连接到 **root** 节点的完整路径为 **/**。

![Root Node Properties][1]

## /aliases 节点

 - **/aliases** 节点用来定义一个或多个别名属性。

 - **/aliases** 节点应位于 **Devicetree** 的根节点。

 - 属性名为 **/aliases** 的名称，属性值为 **Devicetree** 中完整的节点路径。

 - **/aliases** 为以下字符集中，1至31个字符组成的小写字符串。

    ![Valid Characters For Alias Names][2]

```
aliases {
    serial0 = &v2m_serial0;
    serial1 = &v2m_serial1;
    serial2 = &v2m_serial2;
    serial3 = &v2m_serial3;
    i2c0 = &v2m_i2c_dvi;
    i2c1 = &v2m_i2c_pcie;
};
```

## /memory 节点

 - 所有的 **Devicetree** 都需要一个 **memory** 节点，用于描述系统的物理内存分布。

 - 如果有多个内存范围，可以创建多个 **memory** 节点，或在单个 **memory** 节点的 **reg** 属性中指定多个范围。

```
#address-cells = 2
#size-cells = 2
memory@0 {
    device_type = "memory";
    reg = <0x000000000 0x00000000 0x00000000 0x80000000 0x000000001 0x00000000 0x00000001 0x00000000>;
};

or

#address-cells = 2
#size-cells = 2
memory@0 {
    device_type = "memory";
    reg = <0x000000000 0x00000000 0x00000000 0x80000000>;
};

memory@100000000 {
    device_type = "memory";
    reg = <0x000000001 0x00000000 0x00000001 0x00000000>;
};
```

## /chosen 节点

该节点并不代表系统中的真实设备，而是描述了系统固件在运行时所选择或指定的参数。

![Chosen Node Properties][3]

```
chosen {
    bootargs = "root=/dev/nfs rw nfsroot=192.168.1.1 console=ttyS0,115200";
};
```

## /cpus 节点

所有 **Devicetree** 都需要一个 **/cpus** 节点。它作为子节点 **cpus** 的容器。

 - #address-cells 表示在子节点 **reg** 属性中，每个元素占用多少个 **u32** 单元。

 - #size-cells 该值为0，指定子节点中的 **reg** 属性组不需要大小。

## /cpus/cpu\* 节点

### 通用属性

![CPU General Properties 1][4]

![CPU General Properties 2][5]

![CPU General Properties 3][6]

### TLB 属性

![Power ISA TLB Properties][7]

### L1 Cache 属性

![Power ISA Cache Properties][8]

```
cpus {
    #address-cells = <1>;
    #size-cells = <0>;
    cpu@0 {
        device_type = "cpu";
        reg = <0>;
        d-cache-block-size = <32>; // L1 - 32 bytes
        i-cache-block-size = <32>; // L1 - 32 bytes
        d-cache-size = <0x8000>; // L1, 32K
        i-cache-size = <0x8000>; // L1, 32K
        timebase-frequency = <82500000>; // 82.5 MHz
        clock-frequency = <825000000>; // 825 MHz
    };
};
```

## 多级和共享cache节点

```
cpus {
    #address-cells = <1>;
    #size-cells = <0>;

    cpu@0 {
        device_type = "cpu";
        reg = <0>;
        cache-unified;
        cache-size = <0x8000>; // L1, 32 KB
        cache-block-size = <32>;
        timebase-frequency = <82500000>; // 82.5 MHz
        next-level-cache = <&L2_0>; // phandle to L2

        L2_0:l2-cache {
            compatible = "cache";
            cache-unified;
            cache-size = <0x40000>; // 256 KB
            cache-sets = <1024>;
            cache-block-size = <32>;
            cache-level = <2>;
            next-level-cache = <&L3>; // phandle to L3

            L3:l3-cache {
                compatible = "cache";
                cache-unified;
                cache-size = <0x40000>; // 256 KB
                cache-sets = <0x400>; // 1024
                cache-block-size = <32>;
                cache-level = <3>;
            };
        };
    };

    cpu@1 {
        device_type = "cpu";
        reg = <1>;
        cache-unified;
        cache-block-size = <32>;
        cache-size = <0x8000>; // L1, 32 KB
        timebase-frequency = <82500000>; // 82.5 MHz
        clock-frequency = <825000000>; // 825 MHz
        cache-level = <2>;
        next-level-cache = <&L2_1>; // phandle to L2

        L2_1:l2-cache {
            compatible = "cache";
            cache-unified;
            cache-size = <0x40000>; // 256 KB
            cache-sets = <0x400>; // 1024
            cache-line-size = <32>; // 32 bytes
            next-level-cache = <&L3>; // phandle to L3
        };
    };
};
```

 [1]: ./images/Root_Node_Properties.PNG
 [2]: ./images/Valid_Characters_For_Alias_Names.PNG
 [3]: ./images/Chosen_Node_Properties.PNG
 [4]: ./images/CPU_General_Properties_1.PNG
 [5]: ./images/CPU_General_Properties_2.PNG
 [6]: ./images/CPU_General_Properties_3.PNG
 [7]: ./images/Power_ISA_TLB_Properties.PNG
 [8]: ./images/Power_ISA_Cache_Properties.PNG
