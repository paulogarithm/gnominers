package home

import (
	"std"
	"strconv"
	"net/url"

	"gno.land/p/moul/txlink"
	"gno.land/p/pol/dao"
)

var polDao *dao.IdeaDAO
var voteId int = 0
var counter uint = 0

// Init

func init() {
	polDao = dao.NewIdeaDAO()
}

// Exported functions

func JoinDao() {
	err := polDao.AddMember(dao.Member(std.PreviousRealm().Address()))
	if err != nil {
		panic(err)
	}
}

func LeaveDao() {
	err := polDao.ExcludeMember(dao.Member(std.PreviousRealm().Address()))
	if err != nil {
		panic(err)
	}
}

func Proposal(title, description string) {
	// unescape the strings
	title, err := url.QueryUnescape(title)
	if err != nil {
		panic(err)
	}
	description, err = url.QueryUnescape(description)
	if err != nil {
		panic(err)
	}

	// create a member & check if its in the dao
	actor := dao.Member(std.PreviousRealm().Address())
	polDao.AssertUserIsMember(actor)

	// create the proposal
	// POTENTIAL ISSUE: I had to reverse it title & description ? ill see why
	prop := dao.NewIdeaProposal(actor, description, title, func()error {
		counter += 1
		return nil
	})
	polDao.Propose(prop)
}

func Vote(vote string, id string) {
	polDao.AssertUserIsMember(dao.Member(std.PreviousRealm().Address()))

	// get id & vote
	propi, err := strconv.Atoi(vote)
	if err != nil {
		panic(err)
	}
	prop := dao.ProposalChoice(uint(propi))
	propId, err := strconv.Atoi(id)
	if err != nil {
		panic(err)
	}
	allProps := polDao.GetProposals()
	if propId >= len(allProps) {
		panic("propID is greater than all proposals")
	}

	// make the user vote
	err = allProps[propId].Vote(prop)
	if err != nil {
		panic(err)
	}
}

func EndVote(id string) {
	polDao.AssertUserIsMember(dao.Member(std.PreviousRealm().Address()))

	// get the id
	propId, err := strconv.Atoi(id)
	if err != nil {
		panic(err)
	}
	allProps := polDao.GetProposals()
	if propId >= len(allProps) {
		panic("propID is greater than all proposals")
	}
}

// Render functions

func renderIntroduction() string {
	out := "# Welcome to the `pol` gno page !\n"
	out += "Hi my name is Paul, I'm a developer and welcome to my page !\n\n"
	out += "### Go check out my super game: [gnomining](/r/pol/gnomining) !\n\n"
	return out
}

func renderDAOStuff() string {
	// display the infos
	out := "## Pol DAO\n"
	out += "## About\n"
	out += "Here is my DAO, based on the `IdeaDAO` in `/p/pol/dao`, go check it out !\n\n"
	joinLink := txlink.Call("JoinDao")
	leaveLink := txlink.Call("LeaveDao")
	dummyVoteLink := txlink.Call("Proposal", "title", "Dummy vote #" + strconv.Itoa(voteId), "description", "Do we increment the counter ?")
	out += "You can [Join](" + joinLink + ") or [Leave](" + leaveLink + ") the dao.\n\n"
	out += "You can also post a [Dummy Vote](" + dummyVoteLink + ") to test. (if you joined)\n\n"
	out += "The counter is now at " + strconv.Itoa(int(counter)) + ".\n\n"

	// display the members
	out += "|Member List|\n|-|\n"
	for _, m := range polDao.GetMembers() {
		out += "|" + m.Address().String() + "|\n"
	}
	out += "\n"

	// display the dao proposals
	out += "## Propositions\n"
	out += "---\n"
	for propId, iprop := range polDao.GetProposals() {
		prop, ok := iprop.(*dao.IdeaProposal)
		if !ok {
			continue
		}
		out += "### " + prop.Title + "\n"
		out += prop.Description + "\n\n"
		var lnk string
		for k, v := range polDao.GetChoicesNames() {
			lnk = txlink.Call("Vote", "vote", strconv.Itoa(int(k)), "id",  strconv.Itoa(propId))
			out += "[" + v + "](" + lnk + ") "
		}
		lnk = txlink.Call("EndVote", "id", strconv.Itoa(propId))
		out += "([End Vote](" + lnk + "))\n\n---\n\n" 
	}
	out += "\n"
	return out
}

func Render(path string) string {
	var out string
	out += renderIntroduction()
	out += "---\n"
	out += renderDAOStuff()
	return out
}
