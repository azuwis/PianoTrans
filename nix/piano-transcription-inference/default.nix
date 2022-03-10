{ stdenv
, lib
, buildPythonPackage
, fetchPypi
, fetchpatch
, fetchurl
, matplotlib
, mido
, librosa
, torchlibrosa
}:

buildPythonPackage rec {
  pname = "piano-transcription-inference";
  version = "0.0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-nbhuSkXuWrekFxwdNHaspuag+3K1cKwq90IpATBpWPY=";
  };

  checkpoint = fetchurl {
    name = "note_F1=0.9677_pedal_F1=0.9186.pth";
    # url = "https://zenodo.org/record/4034264/files/CRNN_note_F1%3D0.9677_pedal_F1%3D0.9186.pth?download=1";
    url = "https://github.com/BambooOnFire/Piano-AI-Transcription/raw/main/piano_transcription_inference_data/note_F1%3D0.9677_pedal_F1%3D0.9186.pth";
    sha256 = "sha256-w/qXMHJb9Kdi8cFLyAzVmG6s2gGwJvWkolJc1geHYUE=";
  };

  propagatedBuildInputs = [
    matplotlib
    mido
    librosa
    torchlibrosa
  ];

  patches = [
    # Fix run against librosa 0.9.0
    # https://github.com/qiuqiangkong/piano_transcription_inference/pull/10
    (fetchpatch {
      url = "https://github.com/qiuqiangkong/piano_transcription_inference/commit/b2d448916be771cd228f709c23c474942008e3e8.patch";
      sha256 = "sha256-8O4VtFij//k3fhcbMRz4J8Iz4AdOPLkuk3UTxuCSy8U=";
    })
  ];

  postPatch = ''
    substituteInPlace piano_transcription_inference/inference.py --replace \
      "checkpoint_path='{}/piano_transcription_inference_data/note_F1=0.9677_pedal_F1=0.9186.pth'.format(str(Path.home()))" \
      "checkpoint_path='${checkpoint}'"
  '';

  # Project has no tests
  doCheck = false;

  meta = with lib; {
    description = "A piano transcription inference package";
    homepage = "https://github.com/qiuqiangkong/piano_transcription_inference";
    license = licenses.mit;
    maintainers = with maintainers; [ azuwis ];
  };
}
