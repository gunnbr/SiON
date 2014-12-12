//----------------------------------------------------------------------------------------------------
// SiOPM Vowel filter
//  Copyright (c) 2009 keim All rights reserved.
//  Distributed under BSD-style license (see org.si.license.txt).
//----------------------------------------------------------------------------------------------------

package org.si.sion.effector;


import org.si.sion.sequencer.SiMMLTable;
import org.si.utils.SLLint;


/** Vowel filter, conbination of 6 peaking filters */
class SiFilterVowel extends SiEffectBase
{
    // variables
    //------------------------------------------------------------
    public static inline var FORMANT_COUNT : Int = 6;
    public var formant : Array<SiFilterVowelFormant>;
    public var outputLevel : Float = 1;
    
    // tap matrix
    private var _t0i0 : Float;private var _t0i1 : Float;private var _t0o0 : Float;private var _t0o1 : Float;
    private var _t1i0 : Float;private var _t1i1 : Float;private var _t1o0 : Float;private var _t1o1 : Float;
    private var _t2i0 : Float;private var _t2i1 : Float;private var _t2o0 : Float;private var _t2o1 : Float;
    private var _t3i0 : Float;private var _t3i1 : Float;private var _t3o0 : Float;private var _t3o1 : Float;
    private var _t4i0 : Float;private var _t4i1 : Float;private var _t4o0 : Float;private var _t4o1 : Float;
    private var _t5i0 : Float;private var _t5i1 : Float;private var _t5o0 : Float;private var _t5o1 : Float;
    
    private var _eventQueue : FormantEvent;
    
    
    
    // constructor
    //------------------------------------------------------------
    /** constructor
     */
    public function new()
    {
        super();
        SiFilterVowelFormant.initialize();
        formant = new Array<SiFilterVowelFormant>();
        for (i in 0...FORMANT_COUNT){formant[i] = new SiFilterVowelFormant();
        }
        _eventQueue = null;
        setFilterBand();
    }
    
    
    
    
    // operations
    //------------------------------------------------------------
    /** set 1st and 2nd formant with delay */
    public function setVowellFormant(outputLevel : Float, formFreq1 : Float, gain1 : Int, formFreq2 : Float, gain2 : Int, delay : Int = 0) : Void
    {
        var ifreq1 : Int = SiFilterVowelFormant.calcFreqIndex(formFreq1);
        var ifreq2 : Int = SiFilterVowelFormant.calcFreqIndex(formFreq2);
        var e : FormantEvent = new FormantEvent(delay, outputLevel, ifreq1, gain1, ifreq2, gain2);
        _eventQueue = e.insertTo(_eventQueue);
    }
    
    
    /** set all peaking filter */
    public function setFilterBand(formFreq1 : Float = 800, gain1 : Int = 36, bandwidth1 : Int = 3,
            formFreq2 : Float = 1300, gain2 : Int = 24, bandwidth2 : Int = 3,
            formFreq3 : Float = 2200, gain3 : Int = 12, bandwidth3 : Int = 3,
            formFreq4 : Float = 3500, gain4 : Int = 9, bandwidth4 : Int = 3,
            formFreq5 : Float = 4500, gain5 : Int = 6, bandwidth5 : Int = 3,
            formFreq6 : Float = 5500, gain6 : Int = 3, bandwidth6 : Int = 3) : Void
    {
        formant[0].update(SiFilterVowelFormant.calcFreqIndex(formFreq1), bandwidth1, gain1);
        formant[1].update(SiFilterVowelFormant.calcFreqIndex(formFreq2), bandwidth2, gain2);
        formant[2].update(SiFilterVowelFormant.calcFreqIndex(formFreq3), bandwidth3, gain3);
        formant[3].update(SiFilterVowelFormant.calcFreqIndex(formFreq4), bandwidth4, gain4);
        formant[4].update(SiFilterVowelFormant.calcFreqIndex(formFreq5), bandwidth5, gain5);
        formant[5].update(SiFilterVowelFormant.calcFreqIndex(formFreq6), bandwidth6, gain6);
    }
    
    
    private function _updateEvent(time : Int) : Int
    {
        while (_eventQueue != null && _eventQueue.time == 0){
            formant[0].update(_eventQueue.ifreq1, 3, _eventQueue.igain1);
            formant[1].update(_eventQueue.ifreq2, 2, _eventQueue.igain2);
            outputLevel = _eventQueue.outputLevel;
            _eventQueue = _eventQueue.next;
        }
        return ((_eventQueue != null)) ? _eventQueue.updateTime(time) : time;
    }
    
    
    
    
    // overrided funcitons
    //------------------------------------------------------------
    /** @private */
    override public function initialize() : Void
    {
        
    }
    
    
    /** @private */
    override public function mmlCallback(args : Array<Float>) : Void
    {
        outputLevel = ((!Math.isNaN(args[0]))) ? (args[0] * 0.01) : 1;
        setFilterBand(((!Math.isNaN(args[1]))) ? args[1] : 800,
                ((!Math.isNaN(args[2]))) ? Math.floor(args[2]) : 30,
                3,
                ((!Math.isNaN(args[3]))) ? args[3] : 1300,
                ((!Math.isNaN(args[4]))) ? Math.floor(args[4]) : 24,
                3,
                ((!Math.isNaN(args[5]))) ? args[5] : 2200,
                ((!Math.isNaN(args[6]))) ? Math.floor(args[6]) : 12,
                3,
                ((!Math.isNaN(args[7]))) ? args[7] : 3500,
                ((!Math.isNaN(args[8]))) ? Math.floor(args[8]) : 9,
                3,
                ((!Math.isNaN(args[9]))) ? args[9] : 4500,
                ((!Math.isNaN(args[10]))) ? Math.floor(args[10]) : 6,
                3,
                ((!Math.isNaN(args[11]))) ? args[11] : 5500,
                ((!Math.isNaN(args[12]))) ? Math.floor(args[12]) : 6,
                3);
    }
    
    
    /** @private */
    override public function prepareProcess() : Int
    {
        _t0i0 = _t0i1 = _t0o0 = _t0o1 = 0;
        _t1i0 = _t1i1 = _t1o0 = _t1o1 = 0;
        _t2i0 = _t2i1 = _t2o0 = _t2o1 = 0;
        _t3i0 = _t3i1 = _t3o0 = _t3o1 = 0;
        _t4i0 = _t4i1 = _t4o0 = _t4o1 = 0;
        _t5i0 = _t5i1 = _t5o0 = _t5o1 = 0;
        return 1;
    }
    
    
    /** @private */
    override public function process(channels : Int, buffer : Array<Float>, startIndex : Int, length : Int) : Int
    {
        var i : Int;
        var imax : Int;
        var istep : Int;
        imax = startIndex + length;
        i = startIndex;
        while (i < imax){
            istep = _updateEvent(length);
            processLFO(buffer, i, istep);
            i += istep;
            length -= istep;
        }
        return 1;
    }
    
    
    /** @private */
    private function processLFO(buffer : Array<Float>, startIndex : Int, length : Int) : Void{
        startIndex <<= 1;
        length <<= 1;
        var i : Int;
        var output : Float;
        var input : Float;
        var imax : Int = startIndex + length;
        var f1ab1 : Float = formant[0].ab1;
        var f1a2 : Float = formant[0].a2;
        var f1b0 : Float = formant[0].b0;
        var f1b2 : Float = formant[0].b2;
        var f2ab1 : Float = formant[1].ab1;
        var f2a2 : Float = formant[1].a2;
        var f2b0 : Float = formant[1].b0;
        var f2b2 : Float = formant[1].b2;
        var f3ab1 : Float = formant[2].ab1;
        var f3a2 : Float = formant[2].a2;
        var f3b0 : Float = formant[2].b0;
        var f3b2 : Float = formant[2].b2;
        var f4ab1 : Float = formant[3].ab1;
        var f4a2 : Float = formant[3].a2;
        var f4b0 : Float = formant[3].b0;
        var f4b2 : Float = formant[3].b2;
        var f5ab1 : Float = formant[4].ab1;
        var f5a2 : Float = formant[4].a2;
        var f5b0 : Float = formant[4].b0;
        var f5b2 : Float = formant[4].b2;
        var f6ab1 : Float = formant[5].ab1;
        var f6a2 : Float = formant[5].a2;
        var f6b0 : Float = formant[5].b0;
        var f6b2 : Float = formant[5].b2;
        i = startIndex;
        while (i < imax){
            input = buffer[i];
            output = f1b0 * input + f1ab1 * _t0i0 + f1b2 * _t0i1 - f1ab1 * _t0o0 - f1a2 * _t0o1;
            _t0i1 = _t0i0;_t0i0 = input;_t0o1 = _t0o0;_t0o0 = input = output;
            output = f2b0 * input + f2ab1 * _t1i0 + f2b2 * _t1i1 - f2ab1 * _t1o0 - f2a2 * _t1o1;
            _t1i1 = _t1i0;_t1i0 = input;_t1o1 = _t1o0;_t1o0 = input = output;
            output = f3b0 * input + f3ab1 * _t2i0 + f3b2 * _t2i1 - f3ab1 * _t2o0 - f3a2 * _t2o1;
            _t2i1 = _t2i0;_t2i0 = input;_t2o1 = _t2o0;_t2o0 = input = output;
            output = f4b0 * input + f4ab1 * _t3i0 + f4b2 * _t3i1 - f4ab1 * _t3o0 - f4a2 * _t3o1;
            _t3i1 = _t3i0;_t3i0 = input;_t3o1 = _t3o0;_t3o0 = input = output;
            output = f5b0 * input + f5ab1 * _t4i0 + f5b2 * _t4i1 - f5ab1 * _t4o0 - f5a2 * _t4o1;
            _t4i1 = _t4i0;_t4i0 = input;_t4o1 = _t4o0;_t4o0 = input = output;
            output = f6b0 * input + f6ab1 * _t5i0 + f6b2 * _t5i1 - f6ab1 * _t5o0 - f6a2 * _t5o1;
            _t5i1 = _t5i0;_t5i0 = input;_t5o1 = _t5o0;_t5o0 = input = output;
            output *= outputLevel;
            if (output < -1)                 output = -1
            else if (output > 1)                 output = 1;
            buffer[i] = output;i++;
            buffer[i] = output;i++;
        }
    }
}




class FormantEvent
{
    public var next : FormantEvent;
    public var ifreq1 : Int;public var igain1 : Int;public var ifreq2 : Int;public var igain2 : Int;
    public var outputLevel : Float;
    public var time : Int;
    
    public function new(time : Int, outputLevel : Float, ifreq1 : Int, igain1 : Int, ifreq2 : Int, igain2 : Int)
    {
        this.time = time;
        this.outputLevel = outputLevel;
        this.ifreq1 = ifreq1;
        this.igain1 = igain1;
        this.ifreq2 = ifreq2;
        this.igain2 = igain2;
    }
    
    public function insertTo(list : FormantEvent) : FormantEvent{
        if (list == null)             return this;
        if (this.time < list.time) {
            this.next = list;
            return this;
        }
        var e : FormantEvent = list;
        while (e.next != null) {
            if (e.time <= this.time && this.time < e.next.time) {
                this.next = e.next;
                e.next = this;
                break;
            }
            e = e.next;
        }
        e.next = this;
        return list;
    }
    
    public function updateTime(prog : Int) : Int{
        if (prog > time)             prog = time;
        var e : FormantEvent = this;
        while (e != null) {
            e.time -= prog;
            e = e.next;
        }
        return prog;
    }
}


class SiFilterVowelFormant
{
    private static var _alphaTable : Array<Array<Float>> = null;
    private static var _cosTable : Array<Float> = null;
    private static var _gainTable : Array<Float> = null;
    private static var _ibandList : Array<Dynamic> = [0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4];
    public static function initialize() : Void{
        if (_alphaTable == null) {
            var iband : Int;
            var ifreq : Int;
            var igain : Int;
            var band : Float;
            var freq : Float;
            var table : Array<Float>;
            var omg : Float;
            var cos : Float;
            var sin : Float;
            var angh : Float;
            _alphaTable = new Array<Array<Float>>();
            for (iband in 0...8){
                _alphaTable[iband] = table = new Array<Float>();
                band = _ibandList[iband];
                ifreq = 0;
                freq = 50;
                while (ifreq < 1024){  // 2^(1/32)  
                    omg = freq * 0.00014247585730565955;  // 2*pi/44100  
                    sin = Math.sin(omg);
                    angh = 0.34657359027997264 * band * omg / sin;  // log(2)*0.5  
                    table[ifreq] = sin * (Math.exp(angh) - Math.exp(-angh)) * 0.5;
                    ifreq++;
                    freq *= 1.0218971486541166;
                }
            }
            _cosTable = new Array<Float>();
            ifreq = 0;
            freq = 50;
            while (ifreq < 1024){  // 2^(1/32)  
                _cosTable[ifreq] = Math.cos(freq * 0.00014247585730565955);
                ifreq++;
                freq *= 1.0218971486541166;
            }
            _gainTable = new Array<Float>();
            for (igain in 0...128) {
                _gainTable[igain] = Math.pow(10, (igain - 32) * 0.025);
            }
        }
    }
    
    public static function calcFreqIndex(frequency : Float) : Int{
        var ifreq : Int = Math.floor((Math.log(frequency) * 1.4426950408889633 - 5.643856189774724) * 32);  // * 1/loge(2) - log2(50)
        if (ifreq < 0)             return 0;
        if (ifreq > 1023)             return 1023;
        return ifreq;
    }
    
    public var ab1 : Float;public var a2 : Float;public var b0 : Float;public var b2 : Float;
    
    public function new()
    {
        clear();
    }
    
    public function clear() : Void{
        b0 = 1;
        ab1 = a2 = b2 = 0;
    }
    
    /** update filtering parameters
     *  @param ifreq frequency index. (0=50[Hz], 32=100[Hz], 64=200[Hz] ...1024=12800[Hz])
     *  @param iband band width index. (0=0.125oct, 1=0.25oct, ...7=16oct)
     *  @param gain gain. ( -32dB - 96dB)
     */
    public function update(ifreq : Int, iband : Int, gain : Int) : Void{
        gain += 32;
        if (gain < 0)             gain = 0
        else if (gain > 127)             gain = 127;
        var alp : Float = _alphaTable[iband][ifreq];
        var A : Float = _gainTable[gain];
        var alpA : Float = alp * A;
        var alpiA : Float = alp / A;
        var ia0 : Float = 1 / (1 + alpiA);
        ab1 = -2 * _cosTable[ifreq] * ia0;
        a2 = (1 - alpiA) * ia0;
        b0 = (1 + alpA) * ia0;
        b2 = (1 - alpA) * ia0;
    }
}


