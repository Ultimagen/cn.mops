import filecmp
import subprocess
from os.path import join as pjoin
from . import get_resource_dir

resources_dir = get_resource_dir(__file__)
script_path = "/cnv/convert_bedGraph_to_Granges.R"

def test_convert_bedGraph_to_Granges(tmpdir):
    in_bedGraph_file = pjoin(resources_dir, "test.bedGraph")
    expected_out_file = pjoin(resources_dir, "expected_test.ReadCounts.rds")
    out_file = pjoin(tmpdir, "test.ReadCounts.rds")

    cmd = [
        "Rscript",
        "--vanilla",
        script_path,
        "-i",
        in_bedGraph_file,
        "-sample_name",
        "test"
    ]
    assert subprocess.check_call(cmd, cwd=tmpdir) == 0
    assert filecmp.cmp(out_file, expected_out_file)
