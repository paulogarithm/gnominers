package gnomining

import (
	"strconv"
	"std"
	"gno.land/r/sys/users"
	"gno.land/p/demo/ownable"
	"gno.land/p/moul/txlink"
)

// The user table
type UserInfo struct {
	Money uint
	GemsCount map[gemType]uint
	Pickaxes []IPickaxe
	Active IPickaxe
	Adress std.Address
	Owner *ownable.Ownable
}

func shorten(str string, of int) string {
	return str[:of] + "..." + str[len(str) - of:]
}

// Display the user great
func (u *UserInfo) GetName() string {
	author := shorten(u.Adress.String(), 4)
	user := users.ResolveAddress(u.Adress)
	if user != nil {
		author = "@" + user.Name()
	}
	return author
}

// The list of users
var USERS = map[string]*UserInfo{}

// The function to log a new user with default values
func Login() {
	caller := std.PreviousRealm().Address()
	infos, ok := USERS[caller.String()]
	if ok {
		panic("user already registered")
	}
	infos = &UserInfo{
		Money: 100,
		GemsCount: map[gemType]uint{},
		Adress: caller,
		Pickaxes: []IPickaxe{ &NormalPickaxe{}, &SuperPickaxe{} },
		Owner: ownable.NewWithAddress(caller),
	}
	for gem := GEM_ROCK; gem < _GEM_END; gem++ {
		infos.GemsCount[gem] = 0
		gem++
	}
	infos.Active = infos.Pickaxes[0]
	USERS[caller.String()] = infos
	return
}

// The function to render the user page
func renderUserPage(map[string]string) string {
	content := "## Here is all the users\n"
	for k, v := range USERS {
		content += "- [" + v.GetName() + "](" + GM_PATH + "?user=" + k + "): " + strconv.Itoa(int(v.Money)) + "\n"
	}
	content += "\n"
	lnk := txlink.Call("Login")
	content += "if you want to play, you can [login](" + lnk + ")\n"
	return content
}