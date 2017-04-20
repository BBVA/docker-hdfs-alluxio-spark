package com.bbva.spark


import scopt.OptionParser

case class Conf(inputFile: String = ".", outputFile: String = ".")

object ConfParser {

  private lazy val parser = new OptionParser[Conf]("scopt") {

    head("WordCount")

    opt[String]('i', "input").required().valueName("<file>")
        .action((input, c) => c.copy(inputFile = input))
        .text("input is a required file property")

    opt[String]('o', "output").required().valueName("<file>")
      .action((output, c) => c.copy(outputFile = output))
      .text("output is a required file property")

    help("help").text("prints this usage text")
  }

  def parseAndRun(args: Seq[String])(runFunc: Conf => Unit): Unit = parser.parse(args, Conf()) match {
    case Some(conf) => runFunc(conf)
    case None => // ignore
  }

}