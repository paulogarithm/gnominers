package gnomining

const SHOP_IMAGE = "https://raw.githubusercontent.com/paulogarithm/gnominers/refs/heads/main/images/gnoshop.png"

func displayShop(params map[string]string) string {
	content := "# Shop\n"
	content += "![Alt text](" + SHOP_IMAGE + " \"Optional title\")\n\n"

	content += "|object|foo|\n"
	content += "|-|-|\n"
	content += "|hello|prout|\n"
	return content
}