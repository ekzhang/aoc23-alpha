// I'm kind of bummed that I didn't get a chance to use Flix's Datalog engine in this problem! It
// would've been fantastic for the solution to Day 5 though.

use Functor.{<$>, <$$>}
use Monad.{>>=}

def parseInts(line: String): Option[List[Int64]] =
    line |> String.words <$$> Int64.fromString |> List.sequence

def concatenateNums(nums: List[Int64]): Option[Int64] =
    Int64.toString <$> nums |> List.fold |> Int64.fromString

def binarySearch(lower: Int64, upper: Int64, predicate: Int64 -> Bool): Int64 =
    if (lower == upper)
        lower
    else
        let mid = (lower + upper) / 2i64;
        if (predicate(mid))
            binarySearch(lower, mid, predicate)
        else
            binarySearch(mid + 1i64, upper, predicate)

///
/// Returns the number of integers `i < time` such that `i * (time - i) > distance`.
///
def beatRecord(time: Int64, distance: Int64): Int64 =
    let halfway = time / 2i64;
    let k = binarySearch(0i64, halfway + 1i64, i -> i * (time - i) > distance);
    if (k > halfway) {
        0i64
    } else {
        time - 2i64 * k + 1i64
    }

def main(): Unit \ IO =
    let result = for (
        file <- File.open("input.txt", File.Mode.ReadOnly) |>
            Result.mapErr(_ -> "Could not open file.");
        times <- File.readLine!(file) |> Result.toOption >>=
            String.stripPrefix(substr = "Time:") >>= parseInts |>
            Option.toOk("Could not parse times.");
        distances <- File.readLine!(file) |> Result.toOption >>=
            String.stripPrefix(substr = "Distance:") >>= parseInts |>
            Option.toOk("Could not parse distances.");
        _ <-
            if (List.length(times) == List.length(distances))
                Ok(())
            else
                Err("Number of times and distances do not match.");
        timesCat <- concatenateNums(times) |> Option.toOk("Could not concatenate times.");
        distancesCat <- concatenateNums(distances) |> Option.toOk("Could not concatenate distances.")
    ) yield {
        // Part 1
        List.zipWith(beatRecord, times, distances) |> List.foldLeft((x, y) -> x * y, 1i64) |> println;

        // Part 2
        beatRecord(timesCat, distancesCat) |> println
    };
    match result {
        case Ok(()) => (),
        case Err(message) => {
            println("Error: " ++ message)
        }
    }
