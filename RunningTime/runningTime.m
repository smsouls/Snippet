
/// 通过string获得selector
SEL myDidBecomeActive = NSSelectorFromString(@"SakuraApplicationDidBecomeActive:");
SEL didBecomeActive = NSSelectorFromString(@"applicationDidBecomeActive:");

/// 为class添加方法,参数分别为1.需要添加方法的类 2.发放的selector 3.方法的函数指针 4.方法所需要的参数
class_addMethod([object class], myDidBecomeActive, (IMP)SakuraApplicationDidBecomeActive, "v@:@");

// 通过某个类得到他的某个方法
Method method = class_getInstanceMethod([object class], didBecomeActive);
Method myMethod = class_getInstanceMethod([object class], myDidBecomeActive);

// 进行方法交换.这里是要实现对app进入前台方法的侵入
method_exchangeImplementations(method, myMethod);

// 定义一个具体的函数实现
static void SakuraApplicationDidBecomeActive(id self, SEL _cmd, id newValue) {
    SEL myDidBecomeActive = NSSelectorFromString(@"SakuraApplicationDidBecomeActive:");
    [self performSelector:myDidBecomeActive withObject:newValue];
    //objc_msgSendSuperCasted(&superclazz, _cmd, newValue);
}


/// 动态的创建一个类,这个的类是以self为子类
- (Class)makeClassWithClassName:(NSString *)ClassName
{
    Class clazz = NSClassFromString(ClassName);
    
    if (clazz) {
        return clazz;
    }
    
    // class doesn't exist yet, make it,以self为子类,也可以改成其他的
    Class originalClazz = object_getClass(self);
    Class myClazz = objc_allocateClassPair(originalClazz, ClassName.UTF8String, 0);
    
    // grab class method's signature so we can borrow it
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(myClazz, @selector(class), (IMP)class, types); //这里的添加和上面那个一样都是函数地址,和参数类型
    
    objc_registerClassPair(myClazz); //创建完以后需要注册
    
    return myClazz;
}


/// 将自己类的isa指针指向别的类
object_setClass(self, clazz);


/// 可以得到一个类的所有的方法实现,通过具体的方法可以得到方法对应的selector
unsigned int methodCount = 0;
Method* methodList = class_copyMethodList(clazz, &methodCount);
SEL thisSelector = method_getName(methodList[i]);

/// 通用的method_swizzle方法
+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)swizzleSel
{
    Method originMethod = class_getInstanceMethod(self, origSel);
    Method swizzleMethod = class_getInstanceMethod(self, swizzleSel);
    
    if (originMethod && swizzleMethod) {
        if (class_addMethod(self, origSel, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
            
            class_replaceMethod(self, swizzleSel,
                                method_getImplementation(originMethod),method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, swizzleMethod);
        }
        return YES;
    }
    
    return NO;
    
}
    
