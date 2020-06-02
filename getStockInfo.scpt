JsOsaDAS1.001.00bplist00�Vscript_Nlet start = new Date();

let debug = false

let yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
let yahooQueryParam = "?modules=price,financialData"

let Numbers = Application('Numbers')
let AppleScript = Application.currentApplication()

Numbers.includeStandardAdditions = true
AppleScript.includeStandardAdditions = true

table = Numbers.documents.byName("Money").sheets.byName("Revolut Trading").tables.byName("Investment Summary")

for (i = 3; i < table.rowCount(); i++) {
	let stock = table.cells.byName(`A${i}`).value()
	prettyLog(stock)
	
	let body = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
	
	let json = JSON.parse(body).quoteSummary.result[0]
	
	let financialData = json.financialData
	prettyLog(financialData)
	
	let price = json.price
	prettyLog(price)
		
	if (!debug) {
		table.cells.byName(`G${i}`).value = `=${financialData.currentPrice.raw}`
		
		if (price.preMarketPrice.raw)
			table.cells.byName(`F${i}`).value = `=${price.preMarketPrice.raw}`
		else
			table.cells.byName(`F${i}`).value = `----------`
			
		if (price.postMarketPrice)
			table.cells.byName(`H${i}`).value = `=${price.postMarketPrice.raw}`
		else
			table.cells.byName(`H${i}`).value = `----------`

		table.cells.byName(`M${i}`).value = `=${financialData.targetHighPrice.raw}`
		table.cells.byName(`N${i}`).value = `=${financialData.targetMedianPrice.raw}`
		table.cells.byName(`O${i}`).value = `=${financialData.targetLowPrice.raw}`
		
		table.cells.byName(`P${i}`).value = `=${financialData.recommendationMean.raw}`
	} else {
		prettyLog(financialData.currentPrice.raw)
		
		if (price.preMarketPrice)
			prettyLog(price.preMarketPrice.raw)
			
		if (price.postMarketPrice)
			prettyLog(price.postMarketPrice.raw)

		prettyLog(financialData.targetHighPrice.raw)
		prettyLog(financialData.targetMedianPrice.raw)
		prettyLog(financialData.targetLowPrice.raw)
		
		prettyLog(financialData.recommendationMean.raw)
	}
}

let time = new Date() - start;

console.log(time / 1000 + " secs")

function prettyLog(object) {
	if (debug)
	    console.log(Automation.getDisplayString(object))
}                              djscr  ��ޭ