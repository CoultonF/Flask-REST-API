package onlinestore

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._
import scala.io.BufferedSource


class BasicSimulation extends Simulation {

	val currentDirectory: String = new java.io.File(".").getCanonicalPath
	var source: BufferedSource = scala.io.Source.fromFile("../external-ip.log")
	var line: String = try source.mkString.replace('\n', ' ').trim finally source.close()
	var ip: String =  "http://"+line

	val json_header = Map("Content-Type" -> "application/json")
	
	val httpProtocol = http
		.baseUrl(ip)
		.acceptHeader("*/*")
		.acceptEncodingHeader("gzip, deflate")
		.acceptLanguageHeader("en-US,en;q=0.5")
		.userAgentHeader("curl/7.68.0")

	object Customer{
		val create = exec(http("Customer Sign Up")
			.post("/api/v1/customer/")
			.headers(Map("Content-Type" -> "application/json"))
			.body(RawFileBody("resources/customer.json"))
			.check(status.is(200))
			.check(jsonPath("$.customer_id").saveAs("customer_id"))
			)

		val login = exec(http("Customer Login")
			.put("/api/v1/customer/login")
				.check(status.is(200))
			.headers(json_header)
			.body(StringBody("""{"cid":"${customer_id}"}"""))
			)

		val read = exec(http("Customer Read")
			.get("/api/v1/customer/")
			.check(status.is(200))
			)

	}
	
	object Returns{
		val create = exec(http("Return Create")
			.put("/api/v1/returns/")
			.headers(json_header)
			.body(RawFileBody("resources/return.json"))
			)
		
		val read = exec(http("Return Read")
			.get("/api/v1/returns/")
			)
	}

	object Cart{

		val create = exec(http("Add to Cart")
			.put("/api/v1/cart/")
			.headers(json_header)
			.body(RawFileBody("resources/cart.json"))
			)

		val read = exec(http("Cart Read")
			.get("/api/v1/returns/")
			)
	}

	object History{
		val create = exec(http("History Create")
			.put("/api/v1/history/")
			.headers(json_header)
			)

		val read = exec(http("History Read")
			.get("/api/v1/history/")
			)
	}


	val customers = scenario("Customer")
	.exec(Customer.create, Customer.login)
	.repeat(1, "i"){
	    exec(Customer.read, Cart.create, Cart.read, History.create, History.read, Returns.create, Returns.read)
	}

	setUp(customers.inject(
	    constantConcurrentUsers(50) during (30 minutes))
	.protocols(httpProtocol))
}
