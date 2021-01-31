JsOsaDAS1.001.00bplist00�Vscript_cvar debug = false
var log = false

var yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
var yahooQueryParam = "?modules=price,financialData"

var stockRow = "A"
var shouldProcessRow = "K"
var currentPriceRow = "M"
var firstForecastRow = "N"

function run(argv) {
	let start = new Date();

	let AppleScript = Application.currentApplication()
	AppleScript.includeStandardAdditions = true

	let table = checkNumbers(AppleScript)	

	if (!table)
		return
		
	let rows = table.rowCount(), headerRows = table.headerRowCount(), footerRows = table.footerRowCount()
	var marketState
	let first = true

	for (i = headerRows + 1; i <= rows - footerRows; i++) {
		let stock = table.cells.byName(`${stockRow}${i}`).value()
		prettyLog(stock)
		
		if (table.cells.byName(`${shouldProcessRow}${i}`).value() === 0)
			continue
		
		let response = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
		
		let json = JSON.parse(response).quoteSummary.result[0]
		let financialData = json.financialData
		let price = json.price
			
		marketState = price.marketState
		
		if (first) {
			writeToCell(table, `${currentPriceRow}${rows}`, marketState, false)
			first = false
		}
		
		let currentPriceCell = `${currentPriceRow}${i}`
		let currentPrice
		if ((marketState === "POST" || marketState === "CLOSED"  || marketState === "PREPRE") && price.postMarketPrice.raw) {
			prettyLog(`${stock}: ${marketState}, postMarketValue `)
			currentPrice = price.postMarketPrice.raw
		} else if (marketState === "PRE" && price.preMarketPrice.raw) {
			prettyLog(`${stock}: ${marketState}, preMarketValue `)
			currentPrice = price.preMarketPrice.raw
		} else {
			prettyLog(`${stock}: ${marketState}, currentPrice`)
			currentPrice = price.regularMarketPrice.raw
		}
		
		writeToCell(table, currentPriceCell, currentPrice)
		
		if (financialData === undefined)
			continue
		
		let targetHighPriceCell = `${String.fromCharCode(firstForecastRow.charCodeAt(0))}${i}`
		writeToCell(table, targetHighPriceCell, financialData.targetHighPrice.raw)
		
		let targetMedianPriceCell = `${String.fromCharCode(firstForecastRow.charCodeAt(0) + 1)}${i}`
		writeToCell(table, targetMedianPriceCell, financialData.targetMedianPrice.raw)
			
		let targetLowPriceCell = `${String.fromCharCode(firstForecastRow.charCodeAt(0) + 2)}${i}`
		writeToCell(table, targetLowPriceCell, financialData.targetLowPrice.raw)
			
		let recommendationMeanCell = `${String.fromCharCode(firstForecastRow.charCodeAt(0) + 3)}${i}`
		writeToCell(table, recommendationMeanCell, financialData.recommendationMean.raw)
		
		let numAnalystsCell = `${String.fromCharCode(firstForecastRow.charCodeAt(0) + 4)}${i}`
		writeToCell(table, numAnalystsCell, financialData.numberOfAnalystOpinions.raw)
	}

	console.log((new Date() - start) / 1000 + " secs")
}

function checkNumbers(app) {
	if (!Application('Numbers').running()) {
		app.displayAlert("Numbers is not running.")
		return null
	}
	
	let Numbers = Application('Numbers')
	Numbers.includeStandardAdditions = true

	let table = Numbers.documents.byName("Money").sheets.byName("Trading").tables.byName("Investment Summary")

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
	if (!debug && (value || value === 0) && (table.cells.byName(cellName).value() !== value)) {
		prettyLog(`Writting Value`)
		table.cells.byName(cellName).value = `${isFormula ? "=" : ""}${value}`
	}
}

function prettyLog(object) {
	if (log)
	    console.log(Automation.getDisplayString(object))
}                              y jscr  ��ޭ