JsOsaDAS1.001.00bplist00�Vscript_
var debug = true

var yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
var yahooQueryParam = "?modules=price,financialData"

function run(argv) {
	let start = new Date();

	let AppleScript = Application.currentApplication()
	AppleScript.includeStandardAdditions = true

	let table = checkNumbers(AppleScript)	

	if (!table)
		return
		
	rows = table.rowCount()
	headerRows = table.headerRowCount()
	footerRows = table.footerRowCount()

	for (i = headerRows + 1; i <= rows - footerRows; i++) {
		let stock = table.cells.byName(`A${i}`).value()
		prettyLog(stock)
		
		let response = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
		
		let json = JSON.parse(response).quoteSummary.result[0]
		
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
			
			if (price.postMarketPrice.raw)
				table.cells.byName(`H${i}`).value = `=${price.postMarketPrice.raw}`
			else
				table.cells.byName(`H${i}`).value = ``

			table.cells.byName(`I${i}`).value = `=${financialData.targetHighPrice.raw}`
			table.cells.byName(`J${i}`).value = `=${financialData.targetMedianPrice.raw}`
			table.cells.byName(`K${i}`).value = `=${financialData.targetLowPrice.raw}`
			
			table.cells.byName(`L${i}`).value = `=${financialData.recommendationMean.raw}`
		} else {
			prettyLog(financialData.currentPrice.raw)
			
			prettyLog(price.preMarketPrice.raw)
			prettyLog(price.postMarketPrice.raw)
			
			prettyLog(financialData.targetHighPrice.raw)
			prettyLog(financialData.targetMedianPrice.raw)
			prettyLog(financialData.targetLowPrice.raw)
			
			prettyLog(financialData.recommendationMean.raw)
		}
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

	let table = Numbers.documents.byName("Money").sheets.byName("Revolut Trading").tables.byName("Investment Summary")

	try {
		table()
	} catch (err) {
		Numbers.displayAlert("Error finding table. Is the document opened?")
		return null
	}

	return table
}

function prettyLog(object) {
	if (debug)
	    console.log(Automation.getDisplayString(object))
}                              
.jscr  ��ޭ