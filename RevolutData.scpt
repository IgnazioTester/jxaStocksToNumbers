JsOsaDAS1.001.00bplist00�Vscript_�var debug = false
var log = false

var yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
var yahooQueryParam = "?modules=price,financialData,summaryProfile"

function run(argv) {
	let start = new Date();

	let AppleScript = Application.currentApplication()
	AppleScript.includeStandardAdditions = true

	let table = checkNumbers(AppleScript)	

	if (!table)
		return
		
	let rows = table.rowCount(), headerRows = table.headerRowCount(), footerRows = table.footerRowCount()
	var marketState

	//for (i = headerRows + 1; i <= rows - footerRows; i++) {
	for (i = headerRows + 1; i <= rows - footerRows; i++) {
		let stock = table.cells.byName(`A${i}`).value()
		prettyLog(stock)
		
		let response = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
		
		let json = JSON.parse(response).quoteSummary.result[0]
		let financialData = json.financialData
		let price = json.price
			
		writeToCell(table, `B${i}`, price.longName, false)
			
		marketState = price.marketState
		
		let currentPrice
		if ((marketState === "POST" || marketState === "CLOSED") && price.postMarketPrice.raw) {
			console.log(`${stock}: ${marketState}, postMarketValue `)
			currentPrice = price.postMarketPrice.raw
		} else if (marketState === "PRE" && price.preMarketPrice.raw) {
			console.log(`${stock}: ${marketState}, preMarketValue `)
			currentPrice = price.preMarketPrice.raw
		} else {
			console.log(`${stock}: ${marketState}, currentPrice`)
			currentPrice = financialData.currentPrice.raw
		}
		
		writeToCell(table, `C${i}`, currentPrice)


		let targetHighPriceCell = `D${i}`
		writeToCell(table, targetHighPriceCell, financialData.targetHighPrice.raw)
			
		let targetMedianPriceCell = `E${i}`
		writeToCell(table, targetMedianPriceCell, financialData.targetMedianPrice.raw)
			
		let targetLowPriceCell = `F${i}`
		writeToCell(table, targetLowPriceCell, financialData.targetLowPrice.raw)
			
		let recommendationMeanCell = `G${i}`
		writeToCell(table, recommendationMeanCell, financialData.recommendationMean.raw)
		
		let numAnalystsCell = `H${i}`
		writeToCell(table, numAnalystsCell, financialData.numberOfAnalystOpinions.raw)
	}
	
	writeToCell(table, `C2`, marketState, false)

	console.log((new Date() - start) / 1000 + " secs")
}

function checkNumbers(app) {
	if (!Application('Numbers').running()) {
		app.displayAlert("Numbers is not running.")
		return null
	}
	
	let Numbers = Application('Numbers')
	Numbers.includeStandardAdditions = true

	let table = Numbers.documents.byName("Revolut Stocks").sheets.byName("Stocks").tables.byName("Stocks")

	try {
		table()
	} catch (err) {
		Numbers.displayAlert("Error finding table. Is the document opened?")
		return null
	}

	return table
}

function writeToCell(table, cellName, value, isFormula = true) {
	prettyLog(`${cellName}: ${value}`)
	if (value && (table.cells.byName(cellName).value() !== value)) {
		table.cells.byName(cellName).value = `${isFormula ? "=" : ""}${value}`
	}
}

function prettyLog(object) {
	if (log)
	    console.log(Automation.getDisplayString(object))
}                              jscr  ��ޭ