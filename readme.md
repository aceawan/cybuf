# Cybuf

A circular buffer in D.

Cybuf is :

- An InputRange, you can iterate on the values in the buffer from the oldest to the newest.

- An OutputRange, you can push values into the buffer.

- A ForwardRange, you can use the save property to have a copy of the circular buffer.

- A BidirectionnalRange, you can iterate on the values in the buffer from the newest to the oldest.

- A RandomAccessRange, you can access to the nth element of the range, the last being the newest, and the first being the oldest.

You can also specify a handler for the overwritten values.

Example :

```d
void printMyValue(int value){
	writeln("I recieved %d", value);
}

auto cb = Cybuf!int(4, &printMyValue);

cb.put([1,2,3,4,5]);

cb_inv = retro(cb);

writeln("The range :");

foreach(i; cb){
	writeln(i);
}

writeln("The inversed range :");

foreach(i; cb_inv){
	writeln(i);
}

writeln("The oldest element :");
writeln(cb[0]);
writeln("The newest element :");
writeln(cb[$-1]);
```

output : 

```
I received 1
The range:
2
3
4
5
The inversed range:
5
4
3
2
The oldest element:
2
The newest element:
5
```
