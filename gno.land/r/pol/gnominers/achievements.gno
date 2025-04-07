package gnominers

var achievements = map[string]IAchievement{
	"rock": &AchMineARock{},
}

type achievementDifficulty uint
const (
	diffEasy achievementDifficulty = iota
	diffMedium
	diffHard
	diffInsane
	diffImpossible
)

var achievementDifficultyNames = map[achievementDifficulty]string {
	diffEasy: 		"Easy",
	diffMedium: 	"Medium",
	diffHard: 		"Hard",
	diffInsane: 	"Insance",
	diffImpossible: "Impossible",
}

type IAchievement interface {
	Description() string
	Difficulty() achievementDifficulty
	Check(session *UserInfo)
}

func CheckAllAchievements(u *UserInfo) {
	for _, v := range achievements {
		v.Check(u)
	}
}

// render

func renderAchievements(params map[string]string) string {
	// Assertions
	user, ok := params["user"]
	if !ok {
		return "user is not specified. [Go back to home](" + gnominersPath + ") to select a user."
	}
	session, ok := userSessions[user]
	if !ok {
		return "this user is not registered. [Go back to home](" + gnominersPath + ") to register."
	}

	// Content
	content := "# Achievements\n"
	content += "Go back to [DashBoard](" + gnominersDashboard + "?user=" + user + ").\n\n"
	for _, a := range session.hidden.achievements {
		content += "- `" + achievementDifficultyNames[a.Difficulty()] + "` - " + a.Description() + "\n"
	}
	return content
}

// achievements

type AchMineARock struct {}

func (a AchMineARock) Description() string {
	return "Mine a rock"
}

func (a AchMineARock) Difficulty() achievementDifficulty {
	return diffEasy
}

func (it *AchMineARock) Check(session *UserInfo) {
	if session.hidden.overallMined < 1 {
		return
	}
	session.hidden.achievements = append(session.hidden.achievements, it)
}