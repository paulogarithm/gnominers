// This is an example of a DAO implementation with a
// poll implementation, with title and description.
//
// Note that you can use some of this idea in your own
// implementation without using all of it.
// Like you can use an IdeaExecutor without having the
// same Proposal.
package dao

import (
	"errors"
	"std"
	"time"
)

// We define the status
const (
	IdeaAccepted ProposalChoice = iota
	IdeaRejected
	IdeaWhiteVote
	IdeaChoiceCount
)

// Then we implement, first, the Executor
type IdeaExecutor struct {
	f func()error
}

func (e *IdeaExecutor) Execute() error {
	return e.f()
}

func NewIdeaExecutor(f func()error) *IdeaExecutor {
	return &IdeaExecutor{f}
}

// Then, the Proposal
type IdeaProposal struct {
	Title string
	Description string
	author Member					// The original author.
	votes map[ProposalChoice]uint	// The actual votes.
	voters []Member 				// The ones who alread votes.
	expires time.Time				// When does the poll expires.
	executor *IdeaExecutor			// Execute the poll
	alive bool						// If the poll is alive
}

func (p *IdeaProposal) GetAuthor() Member {
	return p.author
}

// In this vote system, if >50% of the votes are White, its refused
// Else, its just the most between Accepted & Rejected.
func (p *IdeaProposal) IsAccepted() bool {
	total := 0.
	for _, v := range p.votes {
		total += float64(v)
	}
	if (total == 0) {
		return false
	}
	if (float64(p.votes[IdeaWhiteVote]) / total) > 0.5 {
		return false
	}
	return p.votes[IdeaAccepted] > p.votes[IdeaRejected]
}

func (p *IdeaProposal) ExecuteIfAccepted() error {
	p.alive = false
	if p.IsAccepted() {
		return p.executor.f()
	}
	return nil
}

func (p *IdeaProposal) ExpiresIn() time.Time {
	return p.expires
}

func (p *IdeaProposal) Vote(verdict ProposalChoice) error {
	who := std.PreviousRealm().Address()
	if who.String() == "" || verdict >= IdeaChoiceCount {
		return errors.New("invalid previous realm")
	}
	for _, v := range p.voters {
		if v.Address() == who {
			return errors.New("user already voted")
		}
	}
	p.voters = append(p.voters, Member(who))
	p.votes[verdict] += 1
	return nil
}

func (p *IdeaProposal) IsEnded() bool {
	return !p.alive
}

func NewIdeaProposal(who Member, title, desc string, f func()error) *IdeaProposal {
	exp := time.Now().Add(time.Minute) // One minute for now
	x := &IdeaProposal{
		Title: title,
		Description: desc,
		author: who,
		votes: map[ProposalChoice]uint{},
		voters: []Member{},
		expires: exp,
		executor: NewIdeaExecutor(f),
		alive: true,
	}
	for n := IdeaAccepted; n < IdeaChoiceCount; n++ {
		x.votes[n] = 0
	}
	return x
}

// After all of that we create the DAO and implement the store
type IdeaDAO struct {
	DAO
	props []Proposal
}

func (d *IdeaDAO) GetProposals() []Proposal {
	return d.props
}

func (d *IdeaDAO) Propose(prop Proposal) {
	d.props = append(d.props, prop)
}

func (d *IdeaDAO) GetChoicesNames() map[ProposalChoice]string {
	return map[ProposalChoice]string{
		IdeaAccepted: "Accept",
		IdeaRejected: "Refuse",
		IdeaWhiteVote: "Abstaint",
	}
}

func NewIdeaDAO() *IdeaDAO {
	return &IdeaDAO{
		DAO{members: []Member{}},
		[]Proposal{},
	}
}
