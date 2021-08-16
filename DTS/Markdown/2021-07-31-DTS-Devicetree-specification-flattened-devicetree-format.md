# 二进制格式

## 简介

**DTB** 的数据格式如下：

![Devicetree Structure][1]

## Header

设备树头部的布局由以下结构来定义，所有的字段都是以 **32Bit大端模式** 存储。

```
struct fdt_header
{
    uint32_t magic;
    uint32_t totalsize;
    uint32_t off_dt_struct;
    uint32_t off_dt_strings;
    uint32_t off_mem_rsvmap;
    uint32_t version;
    uint32_t last_comp_version;
    uint32_t boot_cpuid_phys;
    uint32_t size_dt_strings;
    uint32_t size_dt_struct;
};
```

 - **magic**：固定为 **0xd00dfeed**，用来识别该结构是否为 **DTB**。

 - **totalsize**：**DTB** 结构的总字节大小。

 - **off_dt_struct**：**structure block** 的偏移。

 - **off_dt_strings**：**strings block** 的偏移。

 - **off_mem_rsvmap**：**memory reservation block** 的偏移。

 - **version**：该 **DTB** 的版本信息。

 - **last_comp_version**：该 **DTB** 的兼容版本信息。

 - **boot_cpuid_phys**：标识该 **DTB** 在哪一个 **CPU （Physical ID）** 上被引导。

 - **size_dt_strings**：**strings block** 的长度。

 - **size_dt_struct**：**structure block** 的长度。

## Memory reserve map

该区域为客户端程序提供了需要保留的物理内存的列表。该列表由若干描述符组成，每个描述符由以下结构来定义：

```
struct fdt_reserve_entry
{
    uint64_t address;
    uint64_t size;
};
```

该区域定义了一些特殊用途的内存区域，比如 **DTB** 或者 **initrd image** 所在的内存区域。或者在某些系统中，用于 **ARM** 和 **DSP** 进行信息交互的内存区域。这些保留内存区域不会进入内核的内存管理系统。

## Structure block

该结构块描述了 **Devicetree** 自身的结构和内容。它由一系列包含数据的 **tokens** 组成，这些结构被组织成一个线性的树状结构。

 - **FDT_BEGIN_NODE (0x00000001)**：该 **token** 标识了一个 **node** 的开始位置。它的后面跟着 **node-name@unit-address**。下一个 **token** 是除 **FDT_END** 之外的任何 **token**。

 - **FDT_END_NODE (0x00000002)**：该 **token** 标识了一个 **node** 的结束位置。它的后面没有额外数据，所以直接跟随下一个 **token**。它后面可能是除 **FDT_PROP** 之外的任何 **token**。

 - **FDT_PROP (0x00000003)**：该 **token** 标记了一个 **property** 的开始位置。它的后面跟着描述该 **property** 的数据结构，之后为具体的属性值。下一个 **token** 可能是除 **FDT_END** 之外的任何 **token**。

    ```
    struct
    {
        uint32_t len;
        uint32_t nameoff;
    }
    ```

    - len：表示该 **property** 的值的长度（如果为0则为 **empty**）。

    - nameoff：表示该 **property** 的字符串名字在 **strings block** 中的偏移。

 - **FDT_NOP (0x00000004)**：任何解析 **Devicetree** 的程序都将忽略 **FDT_NOP** 。此 **token** 没有额外的数据，因此它后面紧跟着下一个有效令牌。任何 **property** 或 **node** 可以被 **FDT_NOP** 覆盖，以将其从 **Devicetree** 中删除（无需移动树中的其它部分）。

 - **FDT_END (0x00000009)**：该 **token** 标识了一个 **DTB** 的结束位置。

## Strings block

 - 包含使用的所有属性名称的字符串。

 - 这些字符串简单地连接在一起，并通过偏移量从 **structure block** 中进行引用。

 - 该块没有对齐约束。

 - 该块的目的是为了减少 **DTB** 所需要的内存空间。因为在 **Devicetree** 中存在大量的同名属性，比如 **compatible**。

## Alignment

各块的对齐规则如下：

 - **Memory Reservation Block**：8字节对齐。

 - **Structure Block**：4字节对齐。

 - **Strings Block**：不需要对齐。

这样做的好处是：**由于内部均使用偏移地址，因此能够实现地址重定向。**

 [1]: ./images/Devicetree_Structure.PNG

