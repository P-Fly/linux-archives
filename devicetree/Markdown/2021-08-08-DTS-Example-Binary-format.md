# **Devicetree** 的二进制分析

## 安装 **DTC**

**DTC** 是一个将 **DTS** 编译成 **DTB** 的工具，源码位于 **scripts/dtc**目录下。当然我们也可以安装独立的 **DTC** 工具。

```
$ sudo apt-get install device-tree-compiler
```

## 编译与反编译

**DTC** 的常用命令如下：

 - 编译：

    ```
    $ dtc -I dts -O dtb -o dst.dtb src.dts
    ```

 - 反编译：

    ```
    $ dtc -I dtb -O dts -o dst.dts src.dtb
    ```

## 二进制分析

我们以一个实际的例子来解析 **Devicetree** 的二进制结构。

**DTS** 文件源码如下：

```
/dts-v1/;

/memreserve/ 0x40000000 0x01000000;

/ {
    foo-node {
        compatible = "foo";

        bar-node {
            compatible = "bar";
        };
    };
};
```

**DTC** 工具编译命令如下：

```
$ dtc -I dts -O dtb -o demo-devicetree-binary-format.dtb demo-devicetree-binary-format.dts
```

**DTB** 文件分析如下：

 ![Binary Format][1]

## **fdtdump** 工具

**fdtdump** 是一个 **DTB** 分析工具，我们也可以借助该工具分析上面的二进制文件。

```
$ fdtdump -sd demo-devicetree-binary-format.dtb

**** fdtdump is a low-level debugging tool, not meant for general use.
**** If you want to decompile a dtb, you probably want
****     dtc -I dtb -O dts <filename>

Demo-devicetree-binary-format.dtb: found fdt at offset 0
/dts-v1/;
// magic:               0xd00dfeed
// totalsize:           0xab (171)
// off_dt_struct:       0x48
// off_dt_strings:      0xa0
// off_mem_rsvmap:      0x28
// version:             17
// last_comp_version:   16
// boot_cpuid_phys:     0x0
// size_dt_strings:     0xb
// size_dt_struct:      0x58

/memreserve/ 0x40000000 0x1000000;
// 0048: tag: 0x00000001 (FDT_BEGIN_NODE)
/ {
// 0050: tag: 0x00000001 (FDT_BEGIN_NODE)
    foo-node {
// 0060: tag: 0x00000003 (FDT_PROP)
// 00a0: string: compatible
// 006c: value
        compatible = "foo";
// 0070: tag: 0x00000001 (FDT_BEGIN_NODE)
        bar-node {
// 0080: tag: 0x00000003 (FDT_PROP)
// 00a0: string: compatible
// 008c: value
            compatible = "bar";
// 0090: tag: 0x00000002 (FDT_END_NODE)
        };
// 0094: tag: 0x00000002 (FDT_END_NODE)
    };
// 0098: tag: 0x00000002 (FDT_END_NODE)
};
```

 [1]: ./images/Binary_Format.PNG
