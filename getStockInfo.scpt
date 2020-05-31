JsOsaDAS1.001.00bplist00�Vscript_:var start = new Date();

const isLogEnabled = false
const fetchCurrentValue = true
const fetchForecast = true
const writeToNumbers = false

const Numbers = Application('Numbers')
const AppleScript = Application.currentApplication()

const forecastRegexp = /\"wsod_twoCol clearfix\"><p>(.*?)<\/p>/
const estimatesRegexp = /(\d+\.\d+)/g

const yahooURL = "https://query2.finance.yahoo.com/v10/finance/quoteSummary/"
const yahooQueryParam = "?modules=price"
const cnnURL = "https://money.cnn.com/quote/forecast/forecast.html?symb="

Numbers.includeStandardAdditions = true
AppleScript.includeStandardAdditions = true

var table = Numbers.documents.byName("Money").sheets.byName("Revolut Trading").tables.byName("Investment Summary")

for (i = 3; i <= table.rowCount(); i++) {
	let stock = table.cells.byName(`A${i}`).value()
	prettyLog(stock)
	
	if (fetchCurrentValue) {
		prettyLog(`${yahooURL}`)
		let body = AppleScript.doShellScript(`curl -s ${yahooURL + stock + yahooQueryParam}`)
		prettyLog(body)
	
		let marketPrice = JSON.parse(body).quoteSummary.result[0].price.regularMarketPrice.fmt
		prettyLog(marketPrice)
		
		if (writeToNumbers)
			table.cells.byName(`F${i}`).value = `=${marketPrice}`
	}
	
	if (fetchForecast) {
		let forecastResponse = AppleScript.doShellScript(`curl -s ${cnnURL + stock}`)
		
		let forecast = forecastResponse.match(forecastRegexp)[1]
		//prettyLog(forecast)
		
		let estimates = forecast.match(estimatesRegexp)
		prettyLog(estimates)
		
		if (writeToNumbers) {
			table.cells.byName(`K${i}`).value = `=${estimates[1]}`
			table.cells.byName(`L${i}`).value = `=${estimates[0]}`
			table.cells.byName(`M${i}`).value = `=${estimates[2]}`
		}
	}
}

var time = new Date() - start;

console.log(time / 1000 + " secs")

function prettyLog(object) {
	if (isLogEnabled)
	    console.log(Automation.getDisplayString(object))
}                              Pjscr  ��ޭ