package gnominers

const shopImage = "https://raw.githubusercontent.com/paulogarithm/gnoplayground/refs/heads/main/images/gnoshop.png"

func displayShop(params map[string]string) string {
	content := "# Shop\n"
	content += "![Alt text](" + shopImage + " \"Optional title\")\n\n"

	content += "|object|foo|\n"
	content += "|-|-|\n"
	content += "|hello|prout|\n"
	return content
}