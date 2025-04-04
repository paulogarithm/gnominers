package gnomining

import (
	"time"
	"gno.land/p/pol/queryparsing"
	"gno.land/p/pol/notrandom"
)

var RANDOM_MACHINE *notrandom.Machine
// var RANDOM_MACHINE *Machine

const (
	GM_PATH = "/r/pol/gnomining"
	GM_SHOPPATH = GM_PATH + ":shop"
)

var REDIRECTIONS_PATHS = map[string]func(params map[string]string) string {
	"shop": displayShop,
}

// the rendering

func init() {
	// RANDOM_MACHINE = &Machine{Seed: uint64(time.Now().Unix())}
	RANDOM_MACHINE = notrandom.NewMachine(time.Now().Unix())
}

func Render(fullpath string) string {
	// RANDOM_MACHINE = notrandom.NewMachine(time.Now().Unix())
	path, params := queryparsing.Parse(fullpath)
	if redirect, ok := REDIRECTIONS_PATHS[path]; ok {
		return redirect(params)
	}
	if _, ok := params["user"]; ok {
		return renderDashboard(params)
	}
	return renderUserPage(params)
}
