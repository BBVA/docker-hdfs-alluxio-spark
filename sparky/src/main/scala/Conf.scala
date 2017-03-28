import org.rogach.scallop.ScallopConf

class Conf(arguments: Seq[String]) extends ScallopConf(arguments) {
  val spark = opt[String](required = true)
  val input = opt[String](required = true)
  val output = opt[String](default = Some(input + "_out.csv"))
  verify()
}