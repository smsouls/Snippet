#operation的使用，主要对uitableview的优化

在实现具体的operation的时候使用来判断iscancel的属性来判断是否可以return,
1.如果未在执行，并且在队列里面，执行cancel，不会立刻移除队列，但是等到需要执行的时候会直接返回，然后立刻移被除出队列
2.如果此时cancel的operation正在执行，那么cancel无效，但是可以通过3来真正的结束
3.检查cancel属性，然后在return来终止正在运行的operation，然后立刻移被除出队列
4.cancel了某个operation，与此operation对应的denpency无效。
