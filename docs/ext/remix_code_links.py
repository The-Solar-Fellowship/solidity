import base64
import docutils  # pragma pylint: disable=import-error


def insert_node_before(child, new_sibling):
    assert child in child.parent.children

    for position, node in enumerate(child.parent.children):
        if node == child:
            child.parent.insert(position, new_sibling)
            break


def remix_code_url(source_code):
    # NOTE: base64 encoded data may contain +, = and / characters. Remix seems to handle them just
    # fine without any escaping.
    base64_encoded_source = base64.b64encode(source_code.encode('utf-8')).decode('ascii')
    return f"https://remix.ethereum.org/?code={base64_encoded_source}"


def build_remix_link_node(source_code):
    reference_node = docutils.nodes.reference('', '', internal=False, refuri=remix_code_url(source_code))
    reference_node.set_class('remix-link')
    reference_node.append(docutils.nodes.Text("Open in Remix IDE"))

    paragraph_node = docutils.nodes.paragraph()
    paragraph_node.set_class('remix-link-container')
    paragraph_node += reference_node
    return paragraph_node


def insert_remix_link(doctree):
    for literal_block_node in doctree.traverse(docutils.nodes.literal_block):
        assert 'language' in literal_block_node.attributes
        if literal_block_node.attributes['language'].lower() == 'solidity':
            text_nodes = list(literal_block_node.traverse(docutils.nodes.Text))
            assert len(text_nodes) == 1

            insert_node_before(literal_block_node, build_remix_link_node(text_nodes[0]))


def setup(app):
    app.connect(
        'doctree-resolved',
        lambda app, doctree, docname: insert_remix_link(doctree)
    )

    return {
        # NOTE: Need to access _raw_config here because setup() runs before app.config is ready.
        'version': app.config._raw_config['version'],  # pylint: disable=protected-access
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
