# 中断和中断映射

## 简介

在 **Devicetree** 中，存在一个逻辑 **Interrupt tree**，用来表示平台硬件的中断层次结构和路由。

虽然通常被称为 **Interrupt tree**，但它实际上是 **Directed Acyclic Graph**。

中断源到中断控制器的物理布线用 **interrupt-parent** 属性在设备树中表示。产生中断的设备节点包含一个 **interrupt-parent** 属性，指向被路由的中断设备，通常是 **interrupt controller**。如果中断生成设备没有 **interrupt-parent** 属性，则父节点被假定为它的 **interrupt-parent** 节点。

每个产生中断的设备节点包含一个 **interrupts** 属性，描述该设备的一个或多个中断源。每个源都用被称为 **interrupt specifier** 的信息表示。**interrupt specifier** 的格式和含义是特定于 **interrupt domain** 的，即它依赖于其在 **interrupt domain** 根节点上的属性。**\#interrupt-cells** 属性在 **interrupt domain** 的根节点被定义，描述由多少个 **u32** 单元形成一个 **interrupt specifier**。

**interrupt domain** 的 **root** 节点为以下两种设备之一：

 1. **interrupt controller**：

    - 一种物理设备，需要一个驱动程序来处理通过它的中断路由。

    - 它可以级联到另一个 **interrupt domain**。

    - 通过在该节点上定义 **interrupt-controller** 属性来指定该设备。

 2. **interrupt nexus**：

    - 实现从一个 **interrupt domain** 到另一个 **interrupt domain** 之间的转换。

    - 转换是基于特定于域和特定于总线的信息。

    - 域之间的转换是用 **interrupt-map** 属性实现的。

当遍历 **Interrupt tree** 到达没有 **interrupts** 属性的 **interrupt controller** 节点，因此没有显式 **interrupt parent** 节点时，**Interrupt tree** 的 **root** 节点被确定。

![Example Of The Interrupt Tree][1]

## 中断产生设备的属性

### interrupts

属性值类型为 **prop-encoded-array**，由任意数量的 **interrupt specifiers** 构成：

 - 该属性定义了由该设备节点产生的中断信息。

 - **interrupt specifiers** 的格式由该 **interrupt domain** 的 **root** 节点决定。

 - **interrupts** 属性会被 **interrupts-extended** 属性覆盖，通常只使用两者之一。

```
timer@100e4000 {
    compatible = "arm,sp804", "arm,primecell";
    reg = <0x100e4000 0x1000>;
    interrupts = <0 48 4>,
             <0 49 4>;
    clocks = <&oscclk2>, <&oscclk2>;
    clock-names = "timclk", "apb_pclk";
    status = "disabled";
};
```

### interrupt-parent

属性值类型为 **phandle**：

 - 显式定义中断父节点。

 - 如果没有定义该属性，则假定 **Devicetree parent** 为其 **Interrupt parent**。

```
#address-cells = <1>;
#size-cells = <0>;
wlcore: wlcore@0 {
    compatible = "ti,wl1835";
    reg = <2>;
    interrupt-parent = <&gpio3>;
    interrupts = <17 IRQ_TYPE_EDGE_RISING>;
};
```

### interrupts-extended

属性值类型为 **phandle** **prop-encoded-array**：

 - 当一个设备连接到多个 **interrupt controller** 时，应该使用 **interrupts-extended**。它为每个 **interrupt specifier** 提供一个 **interrupt parent**。

 - **interrupts-extended** 与 **interrupts** 相互排斥。如果两者同时存在，则 **interrupts-extended** 优先考虑。

```
timer@10050000 {
    compatible = "samsung,exynos4412-mct";
    reg = <0x10050000 0x800>;
    clocks = <&clock CLK_FIN_PLL>, <&clock CLK_MCT>;
    clock-names = "fin_pll", "mct";
    interrupts-extended = <&gic GIC_SPI 57 IRQ_TYPE_LEVEL_HIGH>,
                  <&combiner 12 5>,
                  <&combiner 12 6>,
                  <&combiner 12 7>,
                  <&gic GIC_PPI 12 IRQ_TYPE_LEVEL_HIGH>;
};
```

## 中断控制器的属性

### \#interrupt-cells

属性值类型为 **u32**：

 - 表明在该 **interrupt domain** 中，由多少个 **u32** 单元形成 **interrupt specifier**。

```
gic: interrupt-controller@1e001000 {
    compatible = "arm,cortex-a9-gic";
    #interrupt-cells = <3>;
    #address-cells = <0>;
    interrupt-controller;
    reg = <0x1e001000 0x1000>,
          <0x1e000100 0x100>;
};
```

### interrupt-controller

属性值类型为 **empty**：

 - 通过定义该属性，表明该节点作为一个中断控制器节点。

## 中断联结属性

如何区分 **interrupt controller** 和 **interrupt nexus**：

 - **interrupt controller** 有 **\#interrupt-cells** 和 **interrupt-controller** 属性。

 - **interrupt nexus** 有 **\#interrupt-cells** 属性，但没有 **interrupt-controller** 属性。

### interrupt-map

属性值类型为 **prop-encoded-array**，由任意数量的 **<child unit address, child interrupt specifier, interrupt-parent, parent unit address, parent interrupt specifier>** 映射条目构成：

 - 该属性桥接了一个 **interrupt domain** 和一组父 **interrupt domain**，并且指定子域中的中断说明符如何映射到各自的父域中。

 - 中断映射是一个表，每一行都是一个由五个组件组成的映射条目。

```
smb: smb@4000000 {
    compatible = "simple-bus";

    #address-cells = <2>;
    #size-cells = <1>;
    ranges = <0 0 0x40000000 0x04000000>,
         <1 0 0x44000000 0x04000000>,
         <2 0 0x48000000 0x04000000>,
         <3 0 0x4c000000 0x04000000>,
         <7 0 0x10000000 0x00020000>;

    #interrupt-cells = <1>;
    interrupt-map-mask = <0 0 63>;
    interrupt-map = <0 0  0 &gic 0  0 4>,
            <0 0  1 &gic 0  1 4>,
            <0 0  2 &gic 0  2 4>,
            <0 0  3 &gic 0  3 4>,
            <0 0  4 &gic 0  4 4>,
            ...
};
```

### interrupt-map-mask

属性值类型为 **prop-encoded-array**：

 - 匹配时通过AND运算，屏蔽掉不需要参与运算的位。

### \#interrupt-cells

与 **interrupt controller** 中的该属性含义一致。

## 示例

![Interrupt Mapping Example][2]

 [1]: ./images/Example_Of_The_Interrupt_Tree.PNG
 [2]: ./images/Interrupt_Mapping_Example.png
