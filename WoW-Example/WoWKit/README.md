### WoWKit &MoMKit

#### WoWFastKV
一个基于mmap的key-value组件，定位是高性能I/O场景，特别是在高频写操作的时候性能超过NSUserDefault
1. 腾讯的MMKV: C++、跨平台
2. FastKV: OC
WoWFastKV 是基于FastKV的Swift实现，会在API封装、类型支持方面拓展

##### 功能点
1. 基于mmap的KV实现
2. API的封装
3. dict -> 内存时机释放

#### WoWFastKV TODO:
1. ~~已经通过WoWCodable 实现了OC NSCoding的类的KV存储，未完成Swift Codable的实现~~
~~直接在Swift方面实现Codable的支持，OC 如果要使用的话用桥接的方式，Codable的自定义类型还是有问题~~
2. 指针操作的代码重构
3. 整体代码设计的重构

#### WoWNetwork
基于 Moya 和 Rx的拓展

#### WoWHybridPageKit
基于WKWebView的封装 


