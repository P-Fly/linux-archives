# **DTC** 如何处理同名节点和同名属性

按照 **Devicetree** 的规定，**node** 中不应该定义同名节点和同名属性。但是在实际使用中，我们可能会有这种需求。

比如：在通用的 **dtsi** 中，我们定义了一些硬件资源。但是在具体的单板上，我们可能又不需要该硬件，因此我们需要在 **dts** 中，将该硬件的属性设置为 **status = "disabled"**。

下例中，我们演示了 **DTC** 如何处理同名节点和同名属性：

```
$ cat Demo-devicetree-merge.dts
/dts-v1/;

/ {
    foo: foo-node {
        compatible = "foo";
        foo-property-A = "node1";
        foo-property-C = "node1";
    };
};

&foo {
    foo-property-B = "node2";
    foo-property-C = "node2";
};

$ dtc -I dts -O dtb -o Demo-devicetree-merge.dtb Demo-devicetree-merge.dts
$ dtc -I dtb -o dts -o Demo-devicetree-merge_disassembly.dts Demo-devicetree-merge.dtb

$ cat Demo-devicetree-merge_disassembly.dts
/dts-v1/;

/ {

        foo-node {
                compatible = "foo";
                foo-property-A = "node1";
                foo-property-C = "node2";
                foo-property-B = "node2";
        };
};
```

可以看见，**DTC** 以 **merge** 的方式合并了两个 **foo-node** 节点（第二个 **foo-node** 节点以引用的方式定义）。不同的属性合并在了一起，并且后面定义的属性 **覆盖** 了前面定义的同名属性。
