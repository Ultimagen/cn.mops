import os
import subprocess
import pandas as pd
import numpy as np
from os.path import join as pjoin
from . import get_resource_dir

resources_dir = get_resource_dir(__file__)
script_path = "/cnv/cnv_calling_using_cnmops.R"


def test_cnv_calling_using_cnmops(tmpdir):
    in_cohort_reads_count_file = pjoin(resources_dir, "merged_cohort_reads_count.rds")
    expected_out_merged_reads_count_file = pjoin(resources_dir, "expected_cohort.cnmops.cnvs.csv")

    out_file = pjoin(tmpdir, "cohort.cnmops.cnvs.csv")
    os.chdir(tmpdir)
    cmd = [
        "Rscript",
        "--vanilla",
        script_path,
        "-cohort_rc",
        in_cohort_reads_count_file,
        "-minWidth",
        "2",
        "-p",
        "1",
    ]
    assert subprocess.check_call(cmd, cwd=tmpdir) == 0
    df = pd.read_csv(out_file)
    df_ref = pd.read_csv(expected_out_merged_reads_count_file)
    assert np.allclose(df.iloc[:, -3:], df_ref.iloc[:, -3:])
