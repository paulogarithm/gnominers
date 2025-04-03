package gnomining

import (
	"strconv"
)

type gemType uint
const (
	GEM_ROCK gemType = iota
	GEM_QUARTZ
	GEM_AMETHYST
	GEM_TOPAZ
	GEM_OPAL
	GEM_SAPPHIRE
	GEM_EMERALD
	GEM_RUBY
	GEM_DIAMOND
	GEM_ALEXANDRITE
	_GEM_END
)

var GEMLOOTTABLE = map[gemType]float64{
	GEM_ROCK: 1,
	GEM_QUARTZ: 0.2,
	GEM_AMETHYST: 0.1,
	GEM_TOPAZ: 0.05,
	GEM_OPAL: 0.042,
	GEM_SAPPHIRE: 0.01,
	GEM_EMERALD: 0.00723,
	GEM_RUBY: 0.0069,
	GEM_DIAMOND: 0.005,
	GEM_ALEXANDRITE: 0.001,
}

var GEMNAMES = []string{
	"rock",
	"quartz",
	"amethyst",
	"topaz",
	"opal",
	"sapphire",
	"emerald",
	"ruby",
	"diamond",
	"alexandrite",
}

func debugGem() string {
	total := 0.
	for _, v := range GEMLOOTTABLE {
		total += v
	}
	content := strconv.FormatFloat(total, 'f', -1, 64)
	content += ", rarest is " + strconv.FormatFloat(GEMLOOTTABLE[GEM_ALEXANDRITE] / total, 'f', -1, 64)
	content += ", lest rare is " + strconv.FormatFloat(GEMLOOTTABLE[GEM_ROCK] / total, 'f', -1, 64)
	return content
}

func RandomGem(m *Machine) (gemType, float64) {
	total := 0.
	for _, v := range GEMLOOTTABLE {
		total += v
	}
	r := MachineRandFloat()
	value := r * total
	for k, v := range GEMLOOTTABLE {
		if value < v {
			return k, r
		} else {
			value -= v
		}
	}
	return GEM_ROCK, r
}