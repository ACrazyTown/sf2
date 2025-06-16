package format.sf2;

import haxe.io.Input;
import format.sf2.Data;

// References: 
// https://github.com/HaxeFoundation/format/blob/master/format/wav/Reader.hx
// https://www.synthfont.com/sfspec24.pdf
// TODO:
// - read DWORDs as UInt32s 
// - validate data instead of blindly assuming it's correct?
class Reader
{
    var i:Input;

    public function new(i:Input)
    {
        this.i = i;
    }

    public function read():SF2
    {
        if (i.readString(4) != "RIFF")
            throw "RIFF header expected";

        // I think this is file size which we probably don't need
        // so just read it to seek ahead
        i.readInt32();

        if (i.readString(4) != "sfbk")
            throw "Expected sfbk";

        var info:INFO = readINFO();
        var sdta:SDTA = readSDTA();
        var pdta:PDTA = readPDTA();

        return 
        {
            sfbk: 
            {
                info: info,
                sdta: sdta,
                pdta: pdta
            }
        };
    }

    function readINFO():INFO
    {
        var info:INFO =
        {
            ifil: null,
            isng: "EMU8000",
            INAM: null
        };

        var ckID:String = i.readString(4);
        var ckSize:Int = i.readInt32();

        if (ckID != "LIST")
            throw 'Expected "LIST" but got "$ckID"';

        var fourcc:String = i.readString(4);
        if (fourcc != "INFO")
            throw 'Expected "INFO" but got "$fourcc"';

        ckSize -= 4;

        while (ckSize > 0)
        {
            var sckID:String = i.readString(4);
            var sckSize:Int = i.readInt32();

            Reflect.setField(info, sckID, readINFOSubChunk(sckID, sckSize));

            // sckID + ckID = 8
            ckSize -= sckSize + 8;
        }

        return info;
    }

    function readSDTA():SDTA
    {
        // TODO: smpl24

        var sdta:SDTA = 
        {
            smpl: null
        };

        var ckID:String = i.readString(4);
        var ckSize:Int = i.readInt32();

        if (ckID != "LIST")
            throw 'Expected "LIST" but got "$ckID"';

        var fourcc:String = i.readString(4);
        if (fourcc != "sdta")
            throw 'Expected "sdta" but got "$fourcc"';

        ckSize -= 4;

        while (ckSize > 0)
        {
            var sckID:String = i.readString(4);
            var sckSize:Int = i.readInt32();

            if (sckID == "smpl")
            {
                trace("reading smpl");
                sdta.smpl = i.read(sckSize);
                trace(sdta.smpl.length);
            }
            else if (sckID == "smpl24")
            {
                throw "smpl24 unimplemented";
            }

            // sckID + ckID = 8
            ckSize -= sckSize + 8;
        }

        return sdta;
    }

    function readPDTA():PDTA
    {
        var pdta:PDTA =
        {
            phdr: null,
            pbag: null,
            pmod: null,
            pgen: null,
            inst: null,
            ibag: null,
            imod: null,
            igen: null,
            shdr: null
        };

        var ckID:String = i.readString(4);
        var ckSize:Int = i.readInt32();

        if (ckID != "LIST")
            throw 'Expected "LIST" but got "$ckID"';

        var fourcc:String = i.readString(4);
        if (fourcc != "pdta")
            throw 'Expected "pdta" but got "$fourcc"';

        ckSize -= 4;

        while (ckSize > 0)
        {
            var sckID:String = i.readString(4);
            var sckSize:Int = i.readInt32();

            Reflect.setField(pdta, sckID, readPDTASubChunk(sckID, sckSize));

            // sckID + ckID = 8
            ckSize -= sckSize + 8;
        }

        return pdta;
    }

    function readINFOSubChunk(name:String, size:Int):Dynamic
    {
        switch (name)
        {
            case "ifil", "iver":
                var version:SFVersionTag = 
                {
                    wMajor: i.readUInt16(),
                    wMinor: i.readUInt16()
                };

                return version;

            case "isng", "INAM", "irom", "ICRD", "IENG", "IPRD", "ICOP", "ICMT", "ISFT":
                return i.readString(size);

            default:
                throw 'Tried to read unknown INFO subchunk ($name)';
        }
    }

    function readPDTASubChunk(name:String, size:Int):Dynamic
    {
        switch (name)
        {
            case "phdr":
                var phdr:Array<PHDR> = [];

                while (size > 0)
                {
                    var record:PHDR = {
                        achPresetName: i.readString(20),
                        wPreset: i.readUInt16(),
                        wBank: i.readUInt16(),
                        wPresetBagNdx: i.readUInt16(),
                        dwLibrary: i.readInt32(),
                        dwGenre: i.readInt32(),
                        dwMorphology: i.readInt32()
                    };

                    size -= 38;
                    phdr.push(record);
                }
                
                return phdr;

            case "pbag":
                var pbag:Array<SFPresetBag> = [];

                while (size > 0)
                {
                    var record:SFPresetBag = 
                    {
                        wGenNdx: i.readUInt16(),
                        wModNdx: i.readUInt16()
                    };

                    size -= 4;
                    pbag.push(record);
                }

                return pbag;

            case "pmod":
                var pmod:Array<SFModList> = [];

                while (size > 0)
                {
                    var record:SFModList = 
                    {
                        sfModSrcOper: i.readUInt16(),
                        sfModDestOper: i.readUInt16(),
                        modAmount: i.readInt16(),
                        sfModAmtSrcOper: i.readUInt16(),
                        sfModTransOper: i.readUInt16()

                    }

                    size -= 10;
                    pmod.push(record);
                }

                return pmod;

            case "pgen":
                var pgen:Array<SFGenList> = [];

                while (size > 0)
                {
                    var record:SFGenList =
                    {
                        sfGenOper: i.readUInt16(),
                        genAmount: i.readUInt16()
                    };

                    size -= 4;
                    pgen.push(record);
                }

                return pgen;

            case "inst":
                var inst:Array<SFInst> = [];

                while (size > 0)
                {
                    var record:SFInst =
                    {
                        achInstName: i.readString(20),
                        wInstBagNdx: i.readUInt16()
                    };

                    size -= 22;
                    inst.push(record);
                }

                return inst;

            case "ibag":
                var ibag:Array<SFInstBag> = [];

                while (size > 0)
                {
                    var record:SFInstBag =
                    {
                        wInstGenNdx: i.readUInt16(),
                        wInstModNdx: i.readUInt16()
                    };

                    size -= 4;
                    ibag.push(record);
                }

                return ibag;

            case "imod":
                var imod:Array<SFModList> = [];

                while (size > 0)
                {
                    var record:SFModList =
                    {
                        sfModSrcOper: i.readUInt16(),
                        sfModDestOper: i.readUInt16(),
                        modAmount: i.readInt16(),
                        sfModAmtSrcOper: i.readUInt16(),
                        sfModTransOper: i.readUInt16()
                    };

                    size -= 10;
                    imod.push(record);
                }

                return imod;

            case "igen":
                var igen:Array<SFInstGenList> = [];

                while (size > 0)
                {
                    var record:SFInstGenList =
                    {
                        sfGenOper: i.readUInt16(),
                        genAmount: i.readUInt16()
                    };

                    size -= 4;
                    igen.push(record);
                }

                return igen;

            case "shdr":
                var shdr:Array<SFSample> = [];

                while (size > 0)
                {
                    var record:SFSample =
                    {
                        achSampleName: i.readString(20),
                        dwStart: i.readInt32(),
                        dwEnd: i.readInt32(),
                        dwStartloop: i.readInt32(),
                        dwEndloop: i.readInt32(),
                        dwSampleRate: i.readInt32(),
                        byOriginalPitch: i.readByte(),
                        chPitchCorrection: i.readInt8(),
                        wSampleLink: i.readUInt16(),
                        sfSampleType: i.readUInt16()
                    };

                    size -= 46;
                    shdr.push(record);
                }

                return shdr;

            default:
                throw 'Tried to read unknown PDTA subchunk ($name)';
        }
    }
}
