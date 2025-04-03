package gnomining

type IPickaxe interface{
	HowMuchMining() uint
	String() string
}

// normal pickaxe

type NormalPickaxe struct {
	IPickaxe
}

func (p *NormalPickaxe) HowMuchMining() uint {
	return 1
}

func (p *NormalPickaxe) String() string {
	return "normal pickaxe"
}

// super pickaxe

type SuperPickaxe struct {
	IPickaxe
}

func (p *SuperPickaxe) HowMuchMining() uint {
	return 3
}

func (p *SuperPickaxe) String() string {
	return "super pickaxe"
}
