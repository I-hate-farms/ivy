Introduction
============

Vala stracktrace displays the application stacktrace when your application crashes (yes, like all those other modern languages).

Just add the following lines : 

```java
int main (string[] args) {
    Stacktrace.register_handlers () ;
	  
    stdout.printf("  This program will crash !\n" ) ;

    this_will_crash () ;
    return 0 ;
}
```

And build your application with `-rdynamic` 
```
valac -g -X -rdynamic -o sample <your vala files>
```

The output is :

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/output.png)

[Sample](/samples)
==================