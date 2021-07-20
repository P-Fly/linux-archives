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

```
chosen {
    bootargs = "root=/dev/nfs rw nfsroot=192.168.1.1 console=ttyS0,115200";
};
```

## /cpus 节点



 [1]: ./images/Root_Node_Properties.PNG
 [2]: ./images/Valid_Characters_For_Alias_Names.PNG













