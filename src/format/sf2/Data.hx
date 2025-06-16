package format.sf2;

import haxe.io.Bytes;

typedef SF2 =
{
    sfbk:SFBK
}

typedef SFBK = 
{
    info:INFO,
    sdta:SDTA,
    pdta:PDTA
}

typedef INFO =
{
    ifil:SFVersionTag,
    isng:String,
    INAM:String,
    ?irom:String,
    ?iver:SFVersionTag,
    ?ICRD:String,
    ?IENG:String,
    ?IPRD:String,
    ?ICOP:String,
    ?ICMT:String,
    ?ISFT:String,
}

typedef SFVersionTag =
{
    wMajor:Int,
    wMinor:Int
}

typedef SDTA =
{
    smpl:Bytes,
    ?smpl24:Bytes
}

typedef PDTA =
{
    phdr:Array<PHDR>,
    pbag:Array<SFPresetBag>,
    pmod:Array<SFModList>,
    pgen:Array<SFGenList>,
    inst:Array<SFInst>,
    ibag:Array<SFInstBag>,
    imod:Array<SFModList>,
    igen:Array<SFInstGenList>,
    shdr:Array<SFSample>
}

typedef PHDR =
{
    achPresetName:String,
    wPreset:Int,
    wBank:Int,
    wPresetBagNdx:Int,
    dwLibrary:Int,
    dwGenre:Int,
    dwMorphology:Int
}

typedef SFPresetBag =
{
    wGenNdx:Int,
    wModNdx:Int
}

// TODO: Figure out what these are actually
typedef SFModulator = Int;
typedef SFGenerator = Int;
typedef SFTransform = Int;

// enum abstract SFTransform(Int) from Int to Int
// {
//     var Linear = 0;
//     var AbsoluteValue = 2;
// }

typedef SFModList =
{
    sfModSrcOper:SFModulator,
    sfModDestOper:SFGenerator,
    modAmount:Int,
    sfModAmtSrcOper:SFModulator,
    sfModTransOper:SFTransform
}

typedef SFGenList =
{
    sfGenOper:SFGenerator,
    genAmount:Int
}

typedef SFInst =
{
    achInstName:String,
    wInstBagNdx:Int
}

typedef SFInstBag =
{
    wInstGenNdx:Int,
    wInstModNdx:Int
}

typedef SFInstGenList = SFGenList;

typedef SFSample =
{
    achSampleName:String,
    dwStart:Int,
    dwEnd:Int,
    dwStartloop:Int,
    dwEndloop:Int,
    dwSampleRate:Int,
    byOriginalPitch:Int,
    chPitchCorrection:Int,
    wSampleLink:Int,
    sfSampleType:SFSampleLink
}

enum abstract SFSampleLink(Int) from Int to Int
{
    var monoSample = 1;
    var rightSample = 2;
    var leftSample = 4;
    var linkedSample = 8;
    var RomMonoSample = 0x8001;
    var RomRightSample = 0x8002;
    var RomLeftSample = 0x8004;
    var RomLinkedSample = 0x8008;
}
