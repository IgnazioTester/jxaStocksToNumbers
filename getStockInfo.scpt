JsOsaDAS1.001.00bplist00�Vscript_Zvar debug = false

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
		//prettyLog(financialData)
		
		let price = json.price
		//prettyLog(price)
			
		if (!debug) {
			let marketState = price.marketState
			
			if ((marketState === "POST" || marketState === "CLOSED") && price.postMarketPrice.raw)
				table.cells.byName(`F${i}`).value = `=${price.postMarketPrice.raw}`
			else if (marketState === "PRE" && price.preMarketPrice.raw)
				table.cells.byName(`F${i}`).value = `=${price.preMarketPrice.raw}`
			else
				table.cells.byName(`F${i}`).value = `=${financialData.currentPrice.raw}`

			if (!table.cells.byName(`I${i}`).value() === financialData.targetHighPrice.raw)
				table.cells.byName(`I${i}`).value = `=${financialData.targetHighPrice.raw}`
			if (!table.cells.byName(`J${i}`).value() === financialData.targetMedianPrice.raw)
				table.cells.byName(`J${i}`).value = `=${financialData.targetMedianPrice.raw}`
			if (!table.cells.byName(`K${i}`).value() === financialData.targetLowPrice.raw)
				table.cells.byName(`K${i}`).value = `=${financialData.targetLowPrice.raw}`
			if (!table.cells.byName(`L${i}`).value() === financialData.recommendationMean.raw)
				table.cells.byName(`L${i}`).value = `=${financialData.recommendationMean.raw}`
		} else {
			prettyLog(`Market State: ${price.marketState}`)
		
			prettyLog(`Current Price ${financialData.currentPrice.raw}`)
			
			prettyLog(`Pre Market Price: ${price.preMarketPrice.raw}`)
			prettyLog(`Post Market Price: ${price.postMarketPrice.raw}`)
			
			prettyLog(`Target High Price: ${financialData.targetHighPrice.raw}`)
			prettyLog(`Target Median Price: ${financialData.targetMedianPrice.raw}`)
			prettyLog(`Target Low Price: ${financialData.targetLowPrice.raw}`)
			
			prettyLog(`Recommendation Mean: ${financialData.recommendationMean.raw}`)
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
}                              pjscr  ��ޭ