JsOsaDAS1.001.00bplist00�Vscript_�var start = new Date();

const isLogEnabled = false
const fetchCurrentValue = true
const fetchForecast = true
const writeToNumbers = false

const Numbers = Application('Numbers')
const AppleScript = Application.currentApplication()

const forecastRegexp = /\"wsod_twoCol clearfix\"><p>(.*?)<\/p>/
const estimatesRegexp = /(\d+\.\d+)/g

Numbers.includeStandardAdditions = true
AppleScript.includeStandardAdditions = true

var table = Numbers.documents.byName("Money").sheets.byName("Revolut Trading").tables.byName("Investment Summary")

for (i = 3; i <= table.rowCount(); i++) {
	let stock = table.cells.byName(`A${i}`).value()
	prettyLog(stock)
	
	if (fetchCurrentValue) {
		let body = AppleScript.doShellScript(`curl -s https://query1.finance.yahoo.com/v8/finance/chart/${stock}`)
		//prettyLog(body)
	
		let marketPrice = JSON.parse(body).chart.result[0].meta.regularMarketPrice
		prettyLog(marketPrice)
		
		if (writeToNumbers)
			table.cells.byName(`F${i}`).value = `=${marketPrice}`
	}
	
	if (fetchForecast) {
		let forecastResponse = AppleScript.doShellScript(`curl -s https://money.cnn.com/quote/forecast/forecast.html?symb=${stock}`)
		
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
}                              � jscr  ��ޭ