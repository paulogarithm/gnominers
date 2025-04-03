package gnomining

import (
	"strconv"
	"std"
	"time"

	"gno.land/p/moul/txlink"
	"gno.land/p/pol/queryparsing"
)

// globals and types

type UserInfo struct {
	Money uint
	GemsCount map[gemType]uint
	Pickaxes []IPickaxe
	Active IPickaxe
}

var NUMBER float64
var USERS = map[string]*UserInfo{}

const (
	GM_PATH = "/r/pol/gnomining"
	GM_SHOPPATH = GM_PATH + ":shop"
)

const SHOP_IMAGE = "https://cdn.discordapp.com/attachments/1356551469385519208/1357326482040426547/image.png?ex=67efcc4b&is=67ee7acb&hm=a229057ce2130c16a6d54af82f20631d7363532d227edbdf63ddfbaa10ac6e15&"

var REDIRECTIONS_PATHS = map[string]func(params map[string]string) string {
	"shop": displayShop,
}

// public functions

func Login() {
	caller := std.PreviousRealm().Address()
	infos, ok := USERS[caller.String()]
	if !ok {
		infos = &UserInfo{
			Money: 100,
			GemsCount: map[gemType]uint{},
		}
		for gem := GEM_ROCK; gem < _GEM_END; gem++ {
			infos.GemsCount[gem] = 0
			gem++
		}
		infos.Pickaxes = []IPickaxe{ &NormalPickaxe{}, &SuperPickaxe{} }
		infos.Active = infos.Pickaxes[0]
		USERS[caller.String()] = infos
	}
	return
}

func Mine() {
	caller := std.PreviousRealm().Address()
	infos, ok := USERS[caller.String()]
	if !ok {
		return // what the hell would you mine if you are not logged in
	}
	for i := 0; i < int(infos.Active.HowMuchMining()); i++ {
		gem, proba := RandomGem(RANDOM_MACHINE)
		NUMBER = proba
		infos.GemsCount[gem] += 1
	}
}

func Equip(index string) {
	caller := std.PreviousRealm().Address()
	infos, ok := USERS[caller.String()]
	if !ok {
		return
	}
	i, err := strconv.Atoi(index)
	if err != nil {
		return
	}
	infos.Active = infos.Pickaxes[i]
}

func Test() {
	NUMBER += 1
}

// functions

func shorten(str string, of int) string {
	return str[:of] + "..." + str[len(str) - of:]
}

func displayDashboard(params map[string]string) string {
	// some checks
	user, ok := params["user"]
	if !ok {
		return "something went wrong, missing user in params."
	}
	infos, ok := USERS[user]
	if !ok {
		return "you're not logged in."
	}
	_ = infos
	
	// the content
	content := "# Dashboard of " + shorten(user, 4) + "\n"

	// actions
	content += "### Actions\n"
	lnk := txlink.Call("Mine")
	content += "[Mine](" + lnk + ")  --  [Shop](" + GM_SHOPPATH + ")" + "\n\n"

	// money money money, must be funny
	content += "### Money\n"
	content += "Currently, you have " + strconv.Itoa(int(infos.Money)) + " GnoCoins\n"

	// your gems
	content += "### Your Gems\n"
	content += "|Gem|Quantity|Price|\n"
	content += "|-|-|-|\n"
	var gem gemType = GEM_ROCK 
	for gem < _GEM_END {
		count, ok := infos.GemsCount[gem]
		if !ok {
			count = 0
		}
		content += "|" + GEMNAMES[gem] + "|" + strconv.Itoa(int(count)) + "|wip|\n"
		gem++
	}
	content += "\n"

	// your inventory
	content += "### Your inventory\n"
	content += "|Pickaxe|Equip|\n"
	content += "|-|-|\n"
	for index, pick := range infos.Pickaxes {
		content += "|" + pick.String() + "|"
		if pick != infos.Active {
			tx := txlink.Call("Equip", "index", strconv.Itoa(index))
			content += "[equip](" + tx + ")"
		}
		content += "|\n"
	}
	content += "\n"
	return content
}

func displayUsers(map[string]string) string {
	content := "## Here is all the users\n"
	for k, v := range USERS {
		content += "- [" + k + "](" + GM_PATH + "?user=" + k + "): " + strconv.Itoa(int(v.Money)) + "\n"
	}
	content += "\n"
	lnk := txlink.Call("Login")
	content += "if you want to play, you can [login](" + lnk + ")\n"
	return content
}

func displayShop(params map[string]string) string {
	content := "# Shop\n"
	content += "![Alt text](" + SHOP_IMAGE + " \"Optional title\")\n\n"

	content += "|object|foo|\n"
	content += "|-|-|\n"
	content += "|hello|prout|\n"
	return content
}

// the rendering

func Render(fullpath string) string {
	RANDOM_MACHINE.Seed = uint64(time.Now().Unix())
	path, params := queryparsing.Parse(fullpath)
	if redirect, ok := REDIRECTIONS_PATHS[path]; ok {
		return redirect(params)
	}
	if _, ok := params["user"]; ok {
		return displayDashboard(params)
	}
	return displayUsers(params)
}
