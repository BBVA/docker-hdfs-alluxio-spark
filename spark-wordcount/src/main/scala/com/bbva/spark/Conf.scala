package com.bbva.spark


import scopt.OptionParser

case class Conf(inputFile: String = ".")

object ConfParser {

  private lazy val parser = new OptionParser[Conf]("scopt") {

    opt[String]('i', "input").required().valueName("<file>")
        .action((input, c) => c.copy(inputFile = input))
        .text("input is a required file property")

  }

  def parse(args: Seq[String], conf: Conf): Option[Conf] = parser.parse(args, conf)

}