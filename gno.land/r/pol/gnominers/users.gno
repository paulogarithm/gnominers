package gnominers

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
var userSessions = map[string]*UserInfo{}

// The function to log a new user with default values
func Login() {
	caller := std.PreviousRealm().Address()
	infos, ok := userSessions[caller.String()]
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
	for gem := gemRock; gem < _gemEnd; gem++ {
		infos.GemsCount[gem] = 0
		gem++
	}
	infos.Active = infos.Pickaxes[0]
	userSessions[caller.String()] = infos
	return
}

// The function to render the user page
func renderUserPage(map[string]string) string {
	var content string
	lnk := txlink.Call("Login")
	content += "# GnoMiners\n"
	content += "Welcome to gno miners ! Please select an user realm, or [Login](" + lnk + ") if you want to create your own.\n\n"
	content += "## Here is all the users\n"
	for k, v := range userSessions {
		content += "- [" + v.GetName() + "](" + gnominersPath + "?user=" + k + "): " + strconv.Itoa(int(v.Money)) + "\n"
	}
	content += "\n"
	content += "If you want to play, you can [Login](" + lnk + ")\n"
	return content
}