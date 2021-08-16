# **reg** 属性和 **range** 属性的区别

 - **reg** 属性定义的是自己在父总线地址空间内的地址范围。

    > The reg property describes the address of the device’s resources within the address space defined by its parent bus. Most commonly this means the offsets and lengths of memory-mapped IO register blocks, but may have a different meaning on some bus types. Addresses in the address space defined by the root node are CPU real addresses.

 - **ranges** 属性定义的是自己和父地址空间之间的映射或转换的方法。

    > The ranges property provides a means of defining a mapping or translation between the address space of the bus (the child address space) and the address space of the bus node’s parent (the parent address space).
