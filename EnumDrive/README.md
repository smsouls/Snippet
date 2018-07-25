# Enum的妙用

1.使用enum来管理viewcontroller的状态
case populated([Recording])  使得recording可以存储到enum里面
var currentRecordings: [Recording] {
switch self:
case .populated(let recordings):
return recordings
}


比较state类型
if case .paging(_, let nextPage) = state {

}
