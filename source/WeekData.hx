typedef WeekFile = {
    var songs:Array<String>;
    var characters:Array<String>;
    var name:String;
    var icons:Array<String>;
}

class WeekData {
    public static var list:Array<WeekFile> = [
        {
            songs: ["Tutorial"],
            characters: ["dad", "bf", "gf"],
            name: "",
            icons: ["gf"]
        },
        {
            songs: ["Bopeebo", "Fresh", "DadBattle"],
            characters: ["dad", "bf", "gf"],
            name: "Daddy Dearest",
            icons: ["dad"]
        },
        {
            songs: ["Spookeez", "South", "Monster"],
            characters: ["spooky", "bf", "gf"],
            name: "Spooky Month",
            icons: ["spooky", "spooky", "monster"]
        },
        {
            songs: ["Pico", "Philly", "Blammed"],
            characters: ["pico", "bf", "gf"],
            name: "PICO",
            icons: ["pico"]
        },
        {
            songs: ["Satin-Panties", "High", "Milf"],
            characters: ["mom", "bf", "gf"],
            name: "MOMMY MUST MURDER",
            icons: ["mom"]
        },
        {
            songs: ["Cocoa", "Eggnog", "Winter-Horrorland"],
            characters: ["parents-christmas", "bf", "gf"],
            name: "RED SNOW",
            icons: ["parents-christmas", "parents-christmas", "monster-christmas"]
        },
        {
            songs: ["Senpai", "Roses", "Thorns"],
            characters: ["senpai", "bf", "gf"],
            name: "hating simulator ft. moawling",
            icons: ["senpai", "senpai", "spirit"]
        },
        {
            songs: ["Ugh", "Guns", "Stress"],
            characters: ["tankman", "bf", "gf"],
            name: "TANKMAN",
            icons: ["tankman"]
        }
    ];
    public static var unlocked:Array<Bool> = [true, true, true, true, true, true, true];
}