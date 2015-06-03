module cybuf;

import std.algorithm;
import std.range;
import std.stdio;

struct Cybuf(T){
    alias Handler = void delegate(T value);
    private T[] buf;
    private size_t place;
    private size_t size;
    private Handler handler;

    @disable
    public this();

    public this(size_t length, Handler handler = null){
        this.buf.length = length;
        place = 0;
        size = 0;
        this.handler = handler;
    }

    public this(T[] buf, size_t place, size_t size){
        this.buf = buf;
        this.place = place;
        this.size = size;
    }

    @property
    public T back(){
        return this[$-1];
    }

    @property
    public bool empty(){
        return (size == 0);
    }

    @property
    public T front(){
        return this[0];
    }

    @property
    public size_t length(){
        return size;
    }

    public T opIndex(size_t index)
    in{
        assert(index < size);
    }
    body{
        if(place+index >= buf.length){
            return buf[index - (buf.length - place)];
        }
        else{
            return buf[place + index];
        }
    }

    public size_t opDollar(){
        return size;
    }

    public void popBack(){
        size--;
    }

    public void popFront(){
        place = (place+1 == buf.length) ? 0 : place+1;
        size--;
    }

    public void put(T elem){
        if(size == buf.length && (handler !is null)){
            handler(this[0]);
        }

        if(place+size < buf.length){
            buf[place+size] = elem;
        }
        else{
            buf[size - (buf.length - place)] = elem;
        }

        if(size == buf.length){
            place = (place+1 == buf.length) ? 0 : place+1;
        }
        else{
            size++;
        }
    }

    public void put(T[] elems){
        foreach(e; elems){
            this.put(e);
        }
    }

    public T[] rawBuf(){
        return this.buf;
    }

    public void setHandler(Handler h){
        this.handler = h;
    }

    @property 
    public Cybuf!T save() const
    {
        return Cybuf!T(buf.dup, place, size);
    }
}

//Static checks about the status of the range.
unittest {
    static assert(isInputRange!(Cybuf!int));
    static assert(isOutputRange!(Cybuf!int, int));
    static assert(isForwardRange!(Cybuf!int));
    static assert(isBidirectionalRange!(Cybuf!int));
    static assert(isRandomAccessRange!(Cybuf!int));
}

//Testing Input/Output
unittest {
    auto cb = Cybuf!int(4);

    cb.put([1,2,3]);

    assert(equal(cb.rawBuf(),[1,2,3,0][]));

    cb.put([4,5]);

    assert(equal(cb.rawBuf(),[5,2,3,4][]));
}

//Testing save
unittest {
    auto cb = Cybuf!string(4);

    cb.put(["faa", "fbb", "fcc", "fdd"]);

    auto cb_save = cb.save;

    cb.put(["fee"]);

    assert(!equal(cb.rawBuf(),cb_save.rawBuf()));
}

//Testing backward iterating
unittest {
    auto cb = Cybuf!int(6);

    cb.put([1,2,3,4,5,6,7,8]);

    auto daplop = retro(cb);

    int[] test;

    foreach(i; daplop){
        test ~= i;
    }

    assert(equal(test, [8,7,6,5,4,3]));
}

//Testing index access
unittest {
    auto cb = Cybuf!int(4);

    cb.put([1,2,3,4,5,6]);

    assert(cb[0] == 3);
    assert(cb[$-1] == 6);
}

//Example of how to use a handler
//Disabled because it is not a real unittest
/*
unittest {

    void printValue(int value){
        writefln("I received the value %d", value);
    }

    auto cb = Cybuf!int(4, &printValue);

    cb.put([1,2,3,4]);

    cb.put([5, 6]);

    cb = Cybuf!int(4);

    cb.setHandler(&printValue);

    cb.put([3,4,5,6,7,8]);
}
*/