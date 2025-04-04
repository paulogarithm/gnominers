package gnomining

import "std"

func assertCallerExists() *UserInfo {
	caller := std.PreviousRealm().Address()
	infos, ok := USERS[caller.String()]
	if !ok {
		panic("user doesnt exists")
	}
	return infos
}