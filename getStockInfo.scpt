JsOsaDAS1.001.00bplist00�Vscript_let start = new Date();

let isLogEnabled = false
let writeToNumbers = true

let yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
let yahooQueryParam = "?modules=financialData"

let Numbers = Application('Numbers')
let AppleScript = Application.currentApplication()

Numbers.includeStandardAdditions = true
AppleScript.includeStandardAdditions = true

let table = Numbers.documents.byName("Money").sheets.byName("Revolut Trading").tables.byName("Investment Summary")

for (i = 3; i <= table.rowCount(); i++) {
	let stock = table.cells.byName(`A${i}`).value()
	prettyLog(stock)
	
	let body = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
	prettyLog(body)
	
	let financialData = JSON.parse(body).quoteSummary.result[0].financialData
	prettyLog(financialData)
		
	if (writeToNumbers) {
		table.cells.byName(`F${i}`).value = `=${financialData.currentPrice.raw}`

		table.cells.byName(`K${i}`).value = `=${financialData.targetHighPrice.raw}`
		table.cells.byName(`L${i}`).value = `=${financialData.targetMedianPrice.raw}`
		table.cells.byName(`M${i}`).value = `=${financialData.targetLowPrice.raw}`
		
		table.cells.byName(`N${i}`).value = `=${financialData.recommendationMean.raw}`
	}
}

let time = new Date() - start;

console.log(time / 1000 + " secs")

function prettyLog(object) {
	if (isLogEnabled)
	    console.log(Automation.getDisplayString(object))
}                              � jscr  ��ޭ