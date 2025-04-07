package gnominers

import (
	"strconv"
	"gno.land/p/moul/txlink"
)

// Mine some gems with your active pickaxe
func Mine() {
	infos := assertCallerExists()
	infos.Owner.AssertCallerIsOwner()
	for i := 0; i < int(infos.Active.HowMuchMining()); i++ {
		gem, _ := RandomGem()
		infos.GemsCount[gem] += 1
	}
}

// The function to equip a pickaxe
func Equip(index string) {
	infos := assertCallerExists()
	i, err := strconv.Atoi(index)
	if err != nil {
		return
	}
	infos.Active = infos.Pickaxes[i]
}

// Render the Dashboard
func renderDashboard(params map[string]string) string {
	// some checks
	user, ok := params["user"]
	if !ok {
		return "something went wrong, missing user in params."
	}
	infos, ok := userSessions[user]
	if !ok {
		return "the user is not logged in."
	}
	_ = infos
	
	// the content
	content := "# Dashboard of " + infos.GetName() + "\n"

	// actions
	content += "### Actions\n"
	lnk := txlink.Call("Mine")
	content += "[Mine](" + lnk + ")  -  [Shop](" + gnominersShopPath + ")" + "\n\n"

	// money money money, must be funny
	content += "### Money\n"
	content += "Currently, you have " + strconv.Itoa(int(infos.Money)) + " GnoCoins\n"

	// your gems
	content += "### Your Gems\n"
	content += "|Gem|Quantity|Price|\n"
	content += "|-|-|-|\n"
	var gem gemType = gemRock 
	for gem < _gemEnd {
		count, ok := infos.GemsCount[gem]
		if !ok {
			count = 0
		}
		content += "|" + gemNames[gem] + "|" + strconv.Itoa(int(count)) + "|wip|\n"
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